import Foundation

// MARK: - NazoTownViewModel

@MainActor
@Observable
final class NazoTownViewModel {

    // MARK: - State

    private(set) var adventures: [Adventure] = []
    var activeAdventure: Adventure?
    var selectedSpot: PuzzleSpot?
    var selectedAnswer: String?
    var showingResult = false
    var lastResult: SpotResult?
    var isShowingHint = false
    var elapsedTime: TimeInterval = 0

    // MARK: - Dependencies

    private let adventureManager = AdventureManager.shared
    private var timer: Timer?

    // MARK: - Computed

    var availableAdventures: [Adventure] {
        adventureManager.adventures
    }

    var isAdventureActive: Bool {
        activeAdventure?.status == .inProgress
    }

    var currentSpot: PuzzleSpot? {
        activeAdventure?.currentSpot
    }

    var totalScore: Int {
        activeAdventure?.totalScore ?? 0
    }

    var progressText: String {
        guard let adventure = activeAdventure else { return "0 / 0" }
        return "\(adventure.results.count) / \(adventure.spots.count)"
    }

    var remainingTimeText: String {
        guard let remaining = activeAdventure?.remainingTime else { return "--:--" }
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var completionStats: CompletionStats? {
        guard let adventure = activeAdventure, adventure.status == .completed else {
            return nil
        }
        return CompletionStats(
            totalSpots: adventure.spots.count,
            solvedCount: adventure.solvedCount,
            totalScore: adventure.totalScore,
            totalTime: adventure.results.reduce(0) { $0 + $1.timeSpent },
            hintsUsed: adventure.results.filter(\.hintUsed).count
        )
    }

    // MARK: - Actions

    func loadAdventures() {
        adventures = adventureManager.adventures
    }

    func startAdventure(_ adventure: Adventure) {
        activeAdventure = adventureManager.startAdventure(adventure)
        selectedSpot = activeAdventure?.currentSpot
        startTimer()
    }

    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
    }

    func submitAnswer() {
        guard let adventure = activeAdventure,
              let spot = selectedSpot,
              let answer = selectedAnswer else {
            return
        }

        let (updatedAdventure, result) = adventureManager.submitAnswer(
            for: adventure,
            spotID: spot.id,
            selectedAnswer: answer,
            timeSpent: elapsedTime,
            hintUsed: isShowingHint
        )

        activeAdventure = updatedAdventure
        lastResult = result
        showingResult = true
    }

    func proceedToNextSpot() {
        showingResult = false
        selectedAnswer = nil
        isShowingHint = false
        elapsedTime = 0

        if activeAdventure?.status == .completed {
            stopTimer()
        } else {
            selectedSpot = activeAdventure?.currentSpot
        }
    }

    func toggleHint() {
        isShowingHint.toggle()
    }

    func resetAdventure() {
        stopTimer()
        activeAdventure = nil
        selectedSpot = nil
        selectedAnswer = nil
        showingResult = false
        lastResult = nil
        isShowingHint = false
        elapsedTime = 0
    }

    func scanNFCTag(tagID: String) {
        guard let adventure = activeAdventure,
              let spot = adventure.spots.first(where: { $0.nfcTagID == tagID }) else {
            return
        }
        selectedSpot = spot
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedTime += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - CompletionStats

struct CompletionStats: Sendable {
    let totalSpots: Int
    let solvedCount: Int
    let totalScore: Int
    let totalTime: TimeInterval
    let hintsUsed: Int

    var accuracy: Double {
        guard totalSpots > 0 else { return 0 }
        return Double(solvedCount) / Double(totalSpots) * 100
    }

    var averageTime: TimeInterval {
        guard totalSpots > 0 else { return 0 }
        return totalTime / Double(totalSpots)
    }

    var rank: String {
        switch totalScore {
        case 600...: "S"
        case 450..<600: "A"
        case 300..<450: "B"
        case 150..<300: "C"
        default: "D"
        }
    }
}
