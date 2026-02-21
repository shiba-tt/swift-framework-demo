import Foundation

// MARK: - DreamStatistics（夢の統計情報）

struct DreamStatistics: Sendable {
    let totalDreams: Int
    let analyzedDreams: Int
    let emotionDistribution: [EmotionalTone: Int]
    let topThemes: [(theme: String, count: Int)]
    let topSymbols: [(symbol: String, count: Int)]
    let averageLucidity: Double
    let averageVividness: Double
    let streakDays: Int
    let weeklyCount: [WeekdayCount]

    var mostFrequentEmotion: EmotionalTone? {
        emotionDistribution.max(by: { $0.value < $1.value })?.key
    }

    var analysisRate: Double {
        guard totalDreams > 0 else { return 0 }
        return Double(analyzedDreams) / Double(totalDreams)
    }
}

// MARK: - WeekdayCount（曜日別記録数）

struct WeekdayCount: Identifiable, Sendable {
    let id = UUID()
    let weekday: String
    let count: Int
}

// MARK: - DreamCalendarEntry（カレンダー表示用）

struct DreamCalendarEntry: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let dreamCount: Int
    let primaryEmotion: EmotionalTone?

    var hasEntry: Bool { dreamCount > 0 }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
