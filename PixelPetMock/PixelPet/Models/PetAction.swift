import Foundation

/// ペットに対して実行できるアクション
struct PetAction: Identifiable, Sendable {
    let id = UUID()
    let type: PetActionType
    let timestamp: Date

    /// アクションの効果テキスト
    var effectText: String {
        type.effectText
    }
}

// MARK: - PetActionType

/// アクションの種類
enum PetActionType: String, CaseIterable, Sendable {
    case feed = "ごはん"
    case play = "あそぶ"
    case clean = "おそうじ"
    case sleep = "おやすみ"

    var emoji: String {
        switch self {
        case .feed: "🍖"
        case .play: "🎾"
        case .clean: "🛁"
        case .sleep: "💤"
        }
    }

    var systemImageName: String {
        switch self {
        case .feed: "fork.knife"
        case .play: "gamecontroller.fill"
        case .clean: "bubbles.and.sparkles.fill"
        case .sleep: "moon.zzz.fill"
        }
    }

    /// 各ステータスへの影響値
    var hungerEffect: Int {
        switch self {
        case .feed: 30
        case .play: -10
        case .clean: 0
        case .sleep: -5
        }
    }

    var happinessEffect: Int {
        switch self {
        case .feed: 10
        case .play: 30
        case .clean: 10
        case .sleep: 5
        }
    }

    var cleanlinessEffect: Int {
        switch self {
        case .feed: -5
        case .play: -15
        case .clean: 40
        case .sleep: 0
        }
    }

    var energyEffect: Int {
        switch self {
        case .feed: 10
        case .play: -20
        case .clean: -5
        case .sleep: 40
        }
    }

    /// アクションの効果説明
    var effectText: String {
        switch self {
        case .feed: "満腹度 +\(hungerEffect)"
        case .play: "機嫌 +\(happinessEffect)"
        case .clean: "清潔度 +\(cleanlinessEffect)"
        case .sleep: "体力 +\(energyEffect)"
        }
    }

    /// クールダウン時間（秒）
    var cooldownSeconds: TimeInterval {
        switch self {
        case .feed: 1800     // 30分
        case .play: 900      // 15分
        case .clean: 3600    // 1時間
        case .sleep: 7200    // 2時間
        }
    }
}
