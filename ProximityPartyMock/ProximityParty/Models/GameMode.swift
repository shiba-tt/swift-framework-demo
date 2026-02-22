import Foundation

/// ゲームモード
enum GameMode: String, Sendable, CaseIterable, Identifiable {
    case spatialTag = "空間鬼ごっこ"
    case treasureHunt = "宝探し"
    case distanceQuiz = "距離当てクイズ"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .spatialTag: return "figure.run"
        case .treasureHunt: return "sparkles"
        case .distanceQuiz: return "ruler"
        }
    }

    var description: String {
        switch self {
        case .spatialTag:
            return "鬼が他のプレイヤーを追いかけます。3m以内に近づくとタッチ判定。逃げる側は鬼との距離をレーダーで確認できます。"
        case .treasureHunt:
            return "1台のiPhoneを「宝」として隠し、他のプレイヤーがUWBの精密距離計測で探します。"
        case .distanceQuiz:
            return "2人のプレイヤー間の距離を当てるクイズ。UWBのセンチメートル精度を活かした新感覚ゲームです。"
        }
    }

    var minPlayers: Int {
        switch self {
        case .spatialTag: return 3
        case .treasureHunt: return 2
        case .distanceQuiz: return 2
        }
    }

    var maxPlayers: Int {
        switch self {
        case .spatialTag: return 8
        case .treasureHunt: return 6
        case .distanceQuiz: return 4
        }
    }

    var tagDistance: Float {
        switch self {
        case .spatialTag: return 3.0
        case .treasureHunt: return 1.0
        case .distanceQuiz: return 0
        }
    }
}
