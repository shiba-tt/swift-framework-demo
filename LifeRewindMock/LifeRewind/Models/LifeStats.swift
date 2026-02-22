import Foundation
import SwiftUI

/// 年間サマリー
struct YearSummary: Identifiable, Sendable {
    let id: UUID
    let year: Int
    let totalEvents: Int
    let busiestMonth: Int
    let busiestMonthEventCount: Int
    let totalHours: Double
    let categoryBreakdown: [CategoryStat]
    let topLocations: [LocationStat]
    let monthlyEventCounts: [Int]
}

/// カテゴリ別統計
struct CategoryStat: Identifiable, Sendable {
    let id: UUID
    let category: LifeCategory
    let eventCount: Int
    let totalHours: Double

    var percentage: Double {
        0
    }
}

/// よく訪れた場所
struct LocationStat: Identifiable, Sendable {
    let id: UUID
    let name: String
    let visitCount: Int
}

/// 月別イベント数
struct MonthlyCount: Identifiable, Sendable {
    let id: UUID
    let month: Int
    let count: Int

    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.shortMonthSymbols[month - 1]
    }
}

/// タイムラインエントリ
struct TimelineEntry: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let title: String
    let category: LifeCategory
    let isHighlight: Bool
}

/// 将来の見通し
struct FutureInsight: Identifiable, Sendable {
    let id: UUID
    let message: String
    let icon: String
}

/// ウィジェット用データ
struct WidgetData: Codable, Sendable {
    let onThisDayTitle: String?
    let onThisDayYearsAgo: Int?
    let totalEventsThisYear: Int
    let topCategoryEmoji: String
    let topCategoryName: String
}
