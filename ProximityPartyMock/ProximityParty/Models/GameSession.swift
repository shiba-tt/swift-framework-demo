import Foundation

/// ゲームセッション
struct GameSession: Sendable, Identifiable {
    let id = UUID()
    let mode: GameMode
    var state: GameState
    var players: [Player]
    var roundNumber: Int
    var totalRounds: Int
    var timeRemaining: Int
    var scores: [UUID: Int]
    var currentTaggerId: UUID?
    var treasureHolderId: UUID?
    var quizTargetDistance: Float?
    var quizGuesses: [UUID: Float]

    /// プレイ中のプレイヤー数
    var activePlayers: Int {
        players.filter { !$0.isTagged || mode != .spatialTag }.count
    }
}

enum GameState: String, Sendable {
    case waiting = "待機中"
    case countdown = "カウントダウン"
    case playing = "プレイ中"
    case roundEnd = "ラウンド終了"
    case finished = "ゲーム終了"

    var icon: String {
        switch self {
        case .waiting: return "hourglass"
        case .countdown: return "timer"
        case .playing: return "play.fill"
        case .roundEnd: return "flag.checkered"
        case .finished: return "trophy.fill"
        }
    }
}

/// 距離当てクイズの結果
struct QuizResult: Sendable, Identifiable {
    let id = UUID()
    let playerName: String
    let guess: Float
    let actual: Float
    let error: Float

    var errorText: String {
        if error < 0.1 {
            return String(format: "誤差 %.0f cm — 神業!", error * 100)
        } else if error < 0.3 {
            return String(format: "誤差 %.0f cm — すごい!", error * 100)
        } else if error < 1.0 {
            return String(format: "誤差 %.0f cm — 惜しい!", error * 100)
        }
        return String(format: "誤差 %.1f m", error)
    }
}
