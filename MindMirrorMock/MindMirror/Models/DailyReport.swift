import Foundation

/// 日次レポート
struct DailyReport: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let score: MentalHealthScore
    let metrics: BehaviorMetrics
    let insights: [Insight]

    /// 日付の表示テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 短い日付テキスト
    var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

/// インサイト（気づき・アドバイス）
struct Insight: Identifiable, Sendable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    let relatedCategory: ScoreCategory
}

/// インサイトの種類
enum InsightType: String, Sendable {
    case positive = "ポジティブ"
    case neutral = "ニュートラル"
    case warning = "注意"

    var systemImageName: String {
        switch self {
        case .positive: "hand.thumbsup.fill"
        case .neutral: "info.circle.fill"
        case .warning: "exclamationmark.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .positive: "green"
        case .neutral: "blue"
        case .warning: "orange"
        }
    }
}

/// 週間サマリー
struct WeeklySummary: Sendable {
    let weekStartDate: Date
    let averageScore: Int
    let scoreTrend: [Int]
    let bestDay: DailyReport?
    let worstDay: DailyReport?
    let keyInsights: [Insight]

    /// 週の表示テキスト
    var weekText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        let start = formatter.string(from: weekStartDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate)!
        let end = formatter.string(from: endDate)
        return "\(start)〜\(end)"
    }
}
