import Foundation

/// 会議の統計情報
struct MeetingStats: Sendable {
    /// 期間内の総会議数
    let totalMeetings: Int

    /// 期間内の総会議時間（分）
    let totalMinutes: Int

    /// 期間内の推定総コスト（円）
    let totalCost: Double

    /// 平均参加者数
    let averageAttendees: Double

    /// 平均会議時間（分）
    let averageDurationMinutes: Int

    /// ディープワーク可能スコア（0.0 〜 1.0）
    let deepWorkScore: Double

    /// 最もコストが高い会議
    let mostExpensiveMeeting: String?

    /// 繰り返し会議の割合
    let recurringRate: Double

    /// 総会議時間テキスト
    var totalTimeText: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    /// コストテキスト（円）
    var totalCostText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalCost)) ?? "¥0"
    }

    /// ディープワークスコアテキスト
    var deepWorkScoreText: String {
        "\(Int(deepWorkScore * 100))"
    }

    static let empty = MeetingStats(
        totalMeetings: 0,
        totalMinutes: 0,
        totalCost: 0,
        averageAttendees: 0,
        averageDurationMinutes: 0,
        deepWorkScore: 1.0,
        mostExpensiveMeeting: nil,
        recurringRate: 0
    )
}

/// 時間帯別の会議密度
struct HourlyMeetingDensity: Identifiable, Sendable {
    let id: Int
    let hour: Int
    let meetingMinutes: Int
    let meetingCount: Int

    /// 密度（0.0 〜 1.0）
    var density: Double {
        min(Double(meetingMinutes) / 60.0, 1.0)
    }

    /// 時刻ラベル
    var hourLabel: String {
        "\(hour)"
    }
}

/// 最適化提案
struct OptimizationSuggestion: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let savingMinutes: Int
    let savingCost: Double

    /// 節約時間テキスト
    var savingTimeText: String {
        let hours = savingMinutes / 60
        let minutes = savingMinutes % 60
        if hours > 0 {
            return "月\(hours)時間\(minutes)分節約"
        }
        return "月\(minutes)分節約"
    }

    /// 節約コストテキスト
    var savingCostText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: savingCost)) ?? "¥0"
    }
}
