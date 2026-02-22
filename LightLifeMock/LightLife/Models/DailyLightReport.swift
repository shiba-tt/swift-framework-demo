import Foundation

/// 日次レポート — 光環境 + 訪問場所 + デバイス使用の統合
struct DailyLightReport: Sendable, Identifiable {
    let id = UUID()
    let date: Date
    let profile: CircadianProfile
    let locationSummary: LocationSummary
    let screenUsage: ScreenUsageSummary
    let insights: [Insight]
}

/// 訪問場所サマリー（SRVisit ベース）
struct LocationSummary: Sendable {
    let totalLocationsVisited: Int
    let timeAtHome: TimeInterval
    let timeOutdoors: TimeInterval
    let locationBreakdown: [LocationEntry]
}

struct LocationEntry: Sendable, Identifiable {
    let id = UUID()
    let category: LocationCategory
    let duration: TimeInterval
    let averageLux: Double

    enum LocationCategory: String, Sendable, CaseIterable {
        case home = "自宅"
        case work = "職場"
        case school = "学校"
        case gym = "ジム"
        case outdoors = "屋外"
        case shop = "買い物"
        case other = "その他"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .work: return "building.2.fill"
            case .school: return "graduationcap.fill"
            case .gym: return "dumbbell.fill"
            case .outdoors: return "leaf.fill"
            case .shop: return "cart.fill"
            case .other: return "mappin.circle.fill"
            }
        }
    }
}

/// 画面使用サマリー（SRDeviceUsageReport ベース）
struct ScreenUsageSummary: Sendable {
    let totalScreenTime: TimeInterval
    let screenWakes: Int
    let unlocks: Int
    /// 夜間（22:00〜06:00）の画面使用時間
    let nightScreenTime: TimeInterval
}

/// インサイト
struct Insight: Sendable, Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String

    enum InsightType: String, Sendable {
        case positive = "良好"
        case warning = "注意"
        case info = "情報"

        var icon: String {
            switch self {
            case .positive: return "hand.thumbsup.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
}

/// 週間トレンドデータ
struct WeeklyTrend: Sendable {
    let reports: [DailyLightReport]

    var averageRhythmScore: Double {
        guard !reports.isEmpty else { return 0 }
        return Double(reports.map(\.profile.rhythmScore).reduce(0, +)) / Double(reports.count)
    }

    var averageDaytimeLux: Double {
        guard !reports.isEmpty else { return 0 }
        return reports.map(\.profile.daytimeAverageLux).reduce(0, +) / Double(reports.count)
    }

    var averageOutdoorTime: Double {
        guard !reports.isEmpty else { return 0 }
        return reports.map(\.locationSummary.timeOutdoors).reduce(0, +) / Double(reports.count)
    }

    var rhythmScoreTrend: TrendDirection {
        guard reports.count >= 3 else { return .stable }
        let recent = reports.suffix(3).map(\.profile.rhythmScore)
        let earlier = reports.prefix(3).map(\.profile.rhythmScore)
        let recentAvg = Double(recent.reduce(0, +)) / Double(recent.count)
        let earlierAvg = Double(earlier.reduce(0, +)) / Double(earlier.count)
        let diff = recentAvg - earlierAvg
        if diff > 5 { return .improving }
        if diff < -5 { return .declining }
        return .stable
    }
}

enum TrendDirection: String, Sendable {
    case improving = "改善傾向"
    case stable = "安定"
    case declining = "低下傾向"

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }
}
