import Foundation

/// ゲームプレイヤー
struct Player: Sendable, Identifiable {
    let id: UUID
    let name: String
    let avatarEmoji: String
    let color: PlayerColor
    var distance: Float
    var direction: SIMD3<Float>
    var isTagged: Bool

    /// プレイヤーの相対角度（ラジアン）
    var angle: Double {
        Double(atan2(direction.x, -direction.z))
    }

    /// 距離のテキスト表示
    var distanceText: String {
        if distance < 1.0 {
            return String(format: "%.0f cm", distance * 100)
        }
        return String(format: "%.1f m", distance)
    }
}

enum PlayerColor: String, Sendable, CaseIterable {
    case red = "赤"
    case blue = "青"
    case green = "緑"
    case orange = "橙"
    case purple = "紫"
    case pink = "桃"

    var emoji: String {
        switch self {
        case .red: return "🔴"
        case .blue: return "🔵"
        case .green: return "🟢"
        case .orange: return "🟠"
        case .purple: return "🟣"
        case .pink: return "🩷"
        }
    }
}

/// ゲーム結果
struct GameResult: Sendable, Identifiable {
    let id = UUID()
    let player: Player
    let rank: Int
    let score: Int
    let achievement: String
}
