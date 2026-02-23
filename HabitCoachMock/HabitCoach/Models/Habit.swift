import Foundation

/// 習慣の定義
struct Habit: Identifiable, Sendable {
    let id: UUID
    let name: String
    let category: HabitCategory
    let targetCount: Int
    let unit: String
    let reminderTime: Date?
    let intentPhrase: String

    init(
        id: UUID = UUID(),
        name: String,
        category: HabitCategory,
        targetCount: Int = 1,
        unit: String = "回",
        reminderTime: Date? = nil,
        intentPhrase: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.targetCount = targetCount
        self.unit = unit
        self.reminderTime = reminderTime
        self.intentPhrase = intentPhrase
    }

    var reminderTimeText: String? {
        guard let time = reminderTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }

    // MARK: - Sample Data

    static let samples: [Habit] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return [
            Habit(
                name: "水を飲む",
                category: .health,
                targetCount: 8,
                unit: "杯",
                reminderTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today),
                intentPhrase: "水を飲んだ"
            ),
            Habit(
                name: "瞑想",
                category: .mindfulness,
                targetCount: 1,
                unit: "回",
                reminderTime: calendar.date(bySettingHour: 7, minute: 0, second: 0, of: today),
                intentPhrase: "瞑想を始めて"
            ),
            Habit(
                name: "読書",
                category: .learning,
                targetCount: 30,
                unit: "分",
                reminderTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today),
                intentPhrase: "読書を記録"
            ),
            Habit(
                name: "ストレッチ",
                category: .exercise,
                targetCount: 1,
                unit: "回",
                reminderTime: calendar.date(bySettingHour: 6, minute: 30, second: 0, of: today),
                intentPhrase: "ストレッチ完了"
            ),
            Habit(
                name: "ウォーキング",
                category: .exercise,
                targetCount: 8000,
                unit: "歩",
                reminderTime: calendar.date(bySettingHour: 17, minute: 30, second: 0, of: today),
                intentPhrase: "散歩に行った"
            ),
            Habit(
                name: "日記を書く",
                category: .mindfulness,
                targetCount: 1,
                unit: "回",
                reminderTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today),
                intentPhrase: "日記を書いた"
            ),
            Habit(
                name: "英語の勉強",
                category: .learning,
                targetCount: 20,
                unit: "分",
                reminderTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today),
                intentPhrase: "英語を勉強した"
            ),
            Habit(
                name: "家族に連絡",
                category: .social,
                targetCount: 1,
                unit: "回",
                reminderTime: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today),
                intentPhrase: "家族に連絡した"
            ),
        ]
    }()
}
