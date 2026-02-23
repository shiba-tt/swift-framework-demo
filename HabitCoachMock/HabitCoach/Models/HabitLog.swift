import Foundation

/// 習慣の実行ログ
struct HabitLog: Identifiable, Sendable {
    let id: UUID
    let habitId: UUID
    let completedAt: Date
    let value: Int

    init(id: UUID = UUID(), habitId: UUID, completedAt: Date = .now, value: Int = 1) {
        self.id = id
        self.habitId = habitId
        self.completedAt = completedAt
        self.value = value
    }

    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: completedAt)
    }
}

/// Siri からの提案
struct SiriSuggestion: Identifiable, Sendable {
    let id: UUID
    let habitName: String
    let message: String
    let suggestedAt: Date
    let reason: String

    init(
        id: UUID = UUID(),
        habitName: String,
        message: String,
        suggestedAt: Date = .now,
        reason: String
    ) {
        self.id = id
        self.habitName = habitName
        self.message = message
        self.suggestedAt = suggestedAt
        self.reason = reason
    }

    static let samples: [SiriSuggestion] = [
        SiriSuggestion(
            habitName: "水を飲む",
            message: "そろそろ水を飲みませんか？前回から2時間経ちました。",
            suggestedAt: Date().addingTimeInterval(-1800),
            reason: "コンテキスト学習: 2時間おきに水分補給する傾向"
        ),
        SiriSuggestion(
            habitName: "ストレッチ",
            message: "朝のストレッチの時間です。いつもこの時間に行っています。",
            suggestedAt: Date().addingTimeInterval(-3600),
            reason: "コンテキスト学習: 毎朝6:30にストレッチする傾向"
        ),
        SiriSuggestion(
            habitName: "読書",
            message: "今日はまだ読書をしていませんよ。寝る前の30分はいかがですか？",
            suggestedAt: Date().addingTimeInterval(-7200),
            reason: "コンテキスト学習: 毎晩21:00に読書する傾向"
        ),
    ]
}

/// 週間ストリーク情報
struct WeeklyStreak: Sendable {
    let habitId: UUID
    let currentStreak: Int
    let longestStreak: Int
    let completedDaysThisWeek: [Bool]

    static func sample(for habitId: UUID) -> WeeklyStreak {
        WeeklyStreak(
            habitId: habitId,
            currentStreak: Int.random(in: 1...14),
            longestStreak: Int.random(in: 7...30),
            completedDaysThisWeek: (0..<7).map { _ in Bool.random() }
        )
    }
}
