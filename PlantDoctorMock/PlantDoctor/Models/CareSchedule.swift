import Foundation

/// 植物のケアスケジュール
struct CareSchedule: Identifiable, Sendable {
    let id = UUID()
    let plantId: UUID
    let plantName: String
    let plantEmoji: String
    let careType: CareType
    let scheduledDate: Date
    var isCompleted: Bool

    /// スケジュールが期限切れかどうか
    var isOverdue: Bool {
        !isCompleted && scheduledDate < Date()
    }

    /// スケジュールまでの日数テキスト
    var daysUntilText: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: scheduledDate).day ?? 0
        if days < 0 {
            return "\(-days)日超過"
        } else if days == 0 {
            return "今日"
        } else if days == 1 {
            return "明日"
        } else {
            return "\(days)日後"
        }
    }

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: scheduledDate)
    }
}

// MARK: - CareType

/// ケアの種類
enum CareType: String, CaseIterable, Sendable {
    case watering = "水やり"
    case fertilizing = "肥料"
    case pruning = "剪定"
    case repotting = "植え替え"
    case pestControl = "害虫対策"
    case diagnosis = "健康チェック"

    var emoji: String {
        switch self {
        case .watering: "💧"
        case .fertilizing: "🧪"
        case .pruning: "✂️"
        case .repotting: "🏺"
        case .pestControl: "🛡️"
        case .diagnosis: "🔍"
        }
    }

    var systemImageName: String {
        switch self {
        case .watering: "drop.fill"
        case .fertilizing: "leaf.arrow.triangle.circlepath"
        case .pruning: "scissors"
        case .repotting: "arrow.triangle.2.circlepath"
        case .pestControl: "shield.fill"
        case .diagnosis: "magnifyingglass"
        }
    }

    /// デフォルトの間隔（日数）
    var defaultIntervalDays: Int {
        switch self {
        case .watering: 7
        case .fertilizing: 30
        case .pruning: 90
        case .repotting: 365
        case .pestControl: 30
        case .diagnosis: 14
        }
    }
}

// MARK: - CareTip

/// 植物のケアヒント
struct CareTip: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let description: String
    let category: CareType
    let season: Season?

    /// 季節
    enum Season: String, CaseIterable, Sendable {
        case spring = "春"
        case summer = "夏"
        case autumn = "秋"
        case winter = "冬"

        var emoji: String {
            switch self {
            case .spring: "🌸"
            case .summer: "☀️"
            case .autumn: "🍁"
            case .winter: "❄️"
            }
        }
    }

    /// デフォルトのヒントリスト
    static let defaults: [CareTip] = [
        CareTip(
            title: "水やりは朝がベスト",
            description: "朝に水やりをすることで、日中の蒸発を防ぎ根まで水が浸透します。",
            category: .watering,
            season: nil
        ),
        CareTip(
            title: "葉水で害虫予防",
            description: "霧吹きで葉に水をかけることで、ハダニなどの害虫を予防できます。",
            category: .pestControl,
            season: .summer
        ),
        CareTip(
            title: "冬場は水やりを控えめに",
            description: "冬は植物の成長が緩やかになるため、水やりの頻度を減らしましょう。",
            category: .watering,
            season: .winter
        ),
        CareTip(
            title: "春は植え替えのチャンス",
            description: "成長期の始まりに植え替えを行うと、根が新しい土に早く馴染みます。",
            category: .repotting,
            season: .spring
        ),
        CareTip(
            title: "肥料は成長期に",
            description: "春〜秋の成長期に月1回の肥料を。冬は控えましょう。",
            category: .fertilizing,
            season: nil
        ),
    ]
}
