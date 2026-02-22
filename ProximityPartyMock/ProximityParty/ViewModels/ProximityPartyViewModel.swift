import Foundation

@MainActor
@Observable
final class ProximityPartyViewModel {
    private(set) var players: [Player] = []
    private(set) var session: GameSession?
    private(set) var gameResults: [GameResult] = []
    private(set) var quizResults: [QuizResult] = []
    private(set) var isDeviceSupported = true

    var selectedMode: GameMode = .spatialTag
    var showModeSelection = false
    var showResults = false
    var quizGuess: String = ""

    private let gameManager = ProximityGameManager.shared

    init() {
        isDeviceSupported = gameManager.checkDeviceSupport()
        setupDemoPlayers()
    }

    // MARK: - Public Actions

    func startGame(mode: GameMode) {
        selectedMode = mode
        let playerCount = Int.random(in: mode.minPlayers...min(mode.maxPlayers, players.count))
        let gamePlayers = Array(players.prefix(playerCount))

        var newSession = GameSession(
            mode: mode,
            state: .playing,
            players: gamePlayers,
            roundNumber: 1,
            totalRounds: mode == .distanceQuiz ? 5 : 3,
            timeRemaining: mode == .spatialTag ? 120 : 60,
            scores: Dictionary(uniqueKeysWithValues: gamePlayers.map { ($0.id, 0) }),
            currentTaggerId: mode == .spatialTag ? gamePlayers.first?.id : nil,
            treasureHolderId: mode == .treasureHunt ? gamePlayers.last?.id : nil,
            quizTargetDistance: mode == .distanceQuiz ? gameManager.generateQuizDistance() : nil,
            quizGuesses: [:]
        )

        if mode == .spatialTag, let taggerId = newSession.currentTaggerId {
            newSession.players = newSession.players.map { p in
                var updated = p
                updated.isTagged = p.id == taggerId
                return updated
            }
        }

        session = newSession
        startSimulation()
    }

    func tagPlayer(_ player: Player) {
        guard var currentSession = session,
              currentSession.mode == .spatialTag,
              player.distance <= currentSession.mode.tagDistance else { return }

        // タグ成功
        currentSession.players = currentSession.players.map { p in
            var updated = p
            if p.id == player.id {
                updated.isTagged = true
            }
            return updated
        }

        // スコア加算
        if let taggerId = currentSession.currentTaggerId {
            currentSession.scores[taggerId, default: 0] += 10
        }

        // 新しい鬼を設定
        currentSession.currentTaggerId = player.id

        session = currentSession
    }

    func submitQuizGuess() {
        guard var currentSession = session,
              currentSession.mode == .distanceQuiz,
              let targetDistance = currentSession.quizTargetDistance,
              let guess = Float(quizGuess) else { return }

        let myId = players.first?.id ?? UUID()
        currentSession.quizGuesses[myId] = guess
        let score = gameManager.calculateQuizScore(guess: guess, actual: targetDistance)
        currentSession.scores[myId, default: 0] += score

        quizResults.append(QuizResult(
            playerName: "あなた",
            guess: guess,
            actual: targetDistance,
            error: abs(guess - targetDistance)
        ))

        // AI プレイヤーの回答
        for player in currentSession.players.dropFirst() {
            let aiGuess = targetDistance + Float.random(in: -2.0...2.0)
            let aiScore = gameManager.calculateQuizScore(guess: aiGuess, actual: targetDistance)
            currentSession.scores[player.id, default: 0] += aiScore

            quizResults.append(QuizResult(
                playerName: player.name,
                guess: aiGuess,
                actual: targetDistance,
                error: abs(aiGuess - targetDistance)
            ))
        }

        // 次のラウンドへ
        currentSession.roundNumber += 1
        if currentSession.roundNumber > currentSession.totalRounds {
            currentSession.state = .finished
            generateGameResults()
        } else {
            currentSession.quizTargetDistance = gameManager.generateQuizDistance()
            currentSession.quizGuesses = [:]
        }

        session = currentSession
        quizGuess = ""
    }

    func findTreasure() {
        guard var currentSession = session,
              currentSession.mode == .treasureHunt else { return }

        let treasurePlayer = currentSession.players.first { $0.id == currentSession.treasureHolderId }
        if let treasure = treasurePlayer, treasure.distance < 1.0 {
            currentSession.state = .finished
            let finderId = players.first?.id ?? UUID()
            currentSession.scores[finderId, default: 0] += 100
            session = currentSession
            generateGameResults()
        }
    }

    func endGame() {
        gameManager.stopSimulation()
        if var currentSession = session {
            currentSession.state = .finished
            session = currentSession
        }
        generateGameResults()
        showResults = true
    }

    func resetGame() {
        gameManager.stopSimulation()
        session = nil
        gameResults = []
        quizResults = []
        showResults = false
    }

    func treasureHint(for distance: Float) -> TreasureHint {
        gameManager.treasureHint(distance: distance)
    }

    // MARK: - Private

    private func setupDemoPlayers() {
        players = gameManager.generateDemoPlayers(count: 6)
    }

    private func startSimulation() {
        guard let currentSession = session else { return }
        gameManager.startSimulation(players: currentSession.players) { [weak self] updatedPlayers in
            Task { @MainActor in
                self?.session?.players = updatedPlayers
                self?.checkGameEvents()
            }
        }
    }

    private func checkGameEvents() {
        guard let currentSession = session else { return }

        switch currentSession.mode {
        case .spatialTag:
            // 鬼と近いプレイヤーをハイライト
            break
        case .treasureHunt:
            // 宝との距離が 1m 以内なら発見可能
            break
        case .distanceQuiz:
            break
        }
    }

    private func generateGameResults() {
        guard let currentSession = session else { return }

        let sorted = currentSession.scores.sorted { $0.value > $1.value }
        gameResults = sorted.enumerated().compactMap { index, entry in
            guard let player = currentSession.players.first(where: { $0.id == entry.key }) else { return nil }
            let achievement: String
            switch index {
            case 0: achievement = "チャンピオン"
            case 1: achievement = "準優勝"
            case 2: achievement = "3位入賞"
            default: achievement = "参加賞"
            }
            return GameResult(player: player, rank: index + 1, score: entry.value, achievement: achievement)
        }
        showResults = true
    }
}
