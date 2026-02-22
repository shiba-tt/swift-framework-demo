import Foundation

/// 気分の統計情報
struct MoodStats: Sendable {
    /// 総記録数
    let totalEntries: Int
    /// 連続記録日数
    let streakDays: Int
    /// 最長連続記録日数
    let longestStreak: Int
    /// 各気分の記録回数
    let moodCounts: [MoodType: Int]
    /// 週間平均スコア
    let weeklyAverageScore: Double
    /// 先週比の変化
    let weeklyScoreChange: Double
    /// 最も多い気分
    let dominantMood: MoodType?

    /// 気分の分布（0.0〜1.0）
    func distribution(for mood: MoodType) -> Double {
        guard totalEntries > 0 else { return 0 }
        return Double(moodCounts[mood] ?? 0) / Double(totalEntries)
    }

    /// 週間平均スコアのレベル
    var weeklyLevel: WeeklyMoodLevel {
        WeeklyMoodLevel.from(score: weeklyAverageScore)
    }

    /// デフォルト値
    static let `default` = MoodStats(
        totalEntries: 0,
        streakDays: 0,
        longestStreak: 0,
        moodCounts: [:],
        weeklyAverageScore: 0,
        weeklyScoreChange: 0,
        dominantMood: nil
    )
}

/// 週間ムードレベル
enum WeeklyMoodLevel: String, Sendable {
    case excellent = "とても良い"
    case good = "良い"
    case average = "普通"
    case low = "やや低め"
    case concern = "要注意"

    static func from(score: Double) -> WeeklyMoodLevel {
        switch score {
        case 4.0...: .excellent
        case 3.0..<4.0: .good
        case 2.5..<3.0: .average
        case 2.0..<2.5: .low
        default: .concern
        }
    }

    var systemImageName: String {
        switch self {
        case .excellent: "sun.max.fill"
        case .good: "cloud.sun.fill"
        case .average: "cloud.fill"
        case .low: "cloud.drizzle.fill"
        case .concern: "cloud.rain.fill"
        }
    }
}
