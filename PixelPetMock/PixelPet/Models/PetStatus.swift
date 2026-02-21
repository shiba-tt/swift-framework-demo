import Foundation

/// ペットのステータス履歴を記録するモデル
struct PetStatusRecord: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let hunger: Int
    let happiness: Int
    let cleanliness: Int
    let energy: Int

    /// 総合コンディション
    var overallCondition: Int {
        (hunger + happiness + cleanliness + energy) / 4
    }

    /// 時刻テキスト
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// MARK: - PetStatusType

/// ステータスの種類（UI 表示用）
enum PetStatusType: String, CaseIterable, Sendable {
    case hunger = "満腹度"
    case happiness = "機嫌"
    case cleanliness = "清潔度"
    case energy = "体力"

    var emoji: String {
        switch self {
        case .hunger: "❤️"
        case .happiness: "⭐"
        case .cleanliness: "✨"
        case .energy: "⚡"
        }
    }

    var systemImageName: String {
        switch self {
        case .hunger: "heart.fill"
        case .happiness: "star.fill"
        case .cleanliness: "sparkles"
        case .energy: "bolt.fill"
        }
    }

    var colorName: String {
        switch self {
        case .hunger: "red"
        case .happiness: "yellow"
        case .cleanliness: "cyan"
        case .energy: "orange"
        }
    }
}

// MARK: - PetAchievement

/// ペットの実績
struct PetAchievement: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let description: String
    let emoji: String
    let unlockedDate: Date?

    /// 実績がアンロック済みかどうか
    var isUnlocked: Bool {
        unlockedDate != nil
    }

    /// デフォルトの実績リスト
    static let defaults: [PetAchievement] = [
        PetAchievement(
            title: "はじめてのごはん",
            description: "初めてペットにごはんをあげた",
            emoji: "🍖",
            unlockedDate: nil
        ),
        PetAchievement(
            title: "お世話マスター",
            description: "全ステータスを80以上にした",
            emoji: "🏆",
            unlockedDate: nil
        ),
        PetAchievement(
            title: "3日連続お世話",
            description: "3日連続でペットのお世話をした",
            emoji: "📅",
            unlockedDate: nil
        ),
        PetAchievement(
            title: "ごきげんマックス",
            description: "機嫌を100にした",
            emoji: "😊",
            unlockedDate: nil
        ),
        PetAchievement(
            title: "1週間の絆",
            description: "ペットを1週間育てた",
            emoji: "💕",
            unlockedDate: nil
        ),
    ]
}
