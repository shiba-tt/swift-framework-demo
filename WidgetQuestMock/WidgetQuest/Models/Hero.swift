import Foundation

/// 勇者（プレイヤーキャラクター）を表すモデル
struct Hero: Identifiable, Sendable {
    let id: UUID
    var name: String
    var heroClass: HeroClass
    var level: Int
    var experience: Int
    var hp: Int
    var maxHP: Int
    var mp: Int
    var maxMP: Int
    var gold: Int
    var attack: Int
    var defense: Int
    var dayCount: Int

    /// 次のレベルに必要な経験値
    var expToNextLevel: Int {
        level * 100
    }

    /// 経験値の進捗率（0.0〜1.0）
    var expProgress: Double {
        Double(experience) / Double(expToNextLevel)
    }

    /// HP の割合（0.0〜1.0）
    var hpRatio: Double {
        Double(hp) / Double(maxHP)
    }

    /// MP の割合（0.0〜1.0）
    var mpRatio: Double {
        Double(mp) / Double(maxMP)
    }

    /// HP のテキスト表示
    var hpText: String {
        "\(hp)/\(maxHP)"
    }

    /// MP のテキスト表示
    var mpText: String {
        "\(mp)/\(maxMP)"
    }

    /// レベルアップに必要な残り経験値
    var remainingExp: Int {
        max(0, expToNextLevel - experience)
    }

    /// ステータスの状態
    var condition: HeroCondition {
        let ratio = hpRatio
        if ratio >= 0.7 {
            return .healthy
        } else if ratio >= 0.4 {
            return .injured
        } else if ratio >= 0.1 {
            return .danger
        } else {
            return .critical
        }
    }

    /// デフォルトの勇者
    static let `default` = Hero(
        id: UUID(),
        name: "アレス",
        heroClass: .warrior,
        level: 1,
        experience: 0,
        hp: 100,
        maxHP: 100,
        mp: 30,
        maxMP: 30,
        gold: 0,
        attack: 12,
        defense: 8,
        dayCount: 1
    )
}

// MARK: - HeroClass

/// 勇者の職業
enum HeroClass: String, CaseIterable, Sendable {
    case warrior = "戦士"
    case mage = "魔法使い"
    case thief = "盗賊"
    case priest = "僧侶"

    var emoji: String {
        switch self {
        case .warrior: "⚔️"
        case .mage: "🔮"
        case .thief: "🗡️"
        case .priest: "✝️"
        }
    }

    var baseHP: Int {
        switch self {
        case .warrior: 120
        case .mage: 70
        case .thief: 90
        case .priest: 80
        }
    }

    var baseMP: Int {
        switch self {
        case .warrior: 20
        case .mage: 80
        case .thief: 40
        case .priest: 60
        }
    }

    var baseAttack: Int {
        switch self {
        case .warrior: 15
        case .mage: 8
        case .thief: 12
        case .priest: 10
        }
    }

    var baseDefense: Int {
        switch self {
        case .warrior: 12
        case .mage: 5
        case .thief: 8
        case .priest: 10
        }
    }
}

// MARK: - HeroCondition

/// 勇者の体調
enum HeroCondition: String, Sendable {
    case healthy = "元気"
    case injured = "負傷"
    case danger = "危険"
    case critical = "瀕死"

    var colorName: String {
        switch self {
        case .healthy: "green"
        case .injured: "yellow"
        case .danger: "orange"
        case .critical: "red"
        }
    }

    var systemImageName: String {
        switch self {
        case .healthy: "heart.fill"
        case .injured: "heart.slash"
        case .danger: "exclamationmark.triangle"
        case .critical: "xmark.octagon.fill"
        }
    }
}
