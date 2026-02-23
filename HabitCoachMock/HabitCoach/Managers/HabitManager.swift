import Foundation

/// 習慣の管理とログ記録を担当するマネージャー
@MainActor
@Observable
final class HabitManager {
    static let shared = HabitManager()

    // MARK: - Observable State

    private(set) var habits: [Habit] = Habit.samples
    private(set) var todayLogs: [HabitLog] = []
    private(set) var suggestions: [SiriSuggestion] = SiriSuggestion.samples
    private(set) var streaks: [UUID: WeeklyStreak] = [:]

    private init() {
        generateSampleLogs()
        generateStreaks()
    }

    // MARK: - Actions

    func logHabit(_ habit: Habit, value: Int = 1) {
        let log = HabitLog(habitId: habit.id, value: value)
        todayLogs.insert(log, at: 0)
    }

    func dismissSuggestion(_ suggestion: SiriSuggestion) {
        suggestions.removeAll { $0.id == suggestion.id }
    }

    // MARK: - Query

    func todayProgress(for habit: Habit) -> Int {
        todayLogs
            .filter { $0.habitId == habit.id }
            .reduce(0) { $0 + $1.value }
    }

    func isCompleted(_ habit: Habit) -> Bool {
        todayProgress(for: habit) >= habit.targetCount
    }

    func completionRatio(for habit: Habit) -> Double {
        let progress = Double(todayProgress(for: habit))
        return min(1.0, progress / Double(habit.targetCount))
    }

    var totalCompletedToday: Int {
        habits.filter { isCompleted($0) }.count
    }

    var totalHabitsCount: Int {
        habits.count
    }

    var overallCompletionRatio: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(totalCompletedToday) / Double(totalHabitsCount)
    }

    func streak(for habit: Habit) -> WeeklyStreak? {
        streaks[habit.id]
    }

    var habitsByCategory: [(category: HabitCategory, habits: [Habit])] {
        let grouped = Dictionary(grouping: habits, by: \.category)
        return HabitCategory.allCases.compactMap { category in
            guard let habits = grouped[category], !habits.isEmpty else { return nil }
            return (category: category, habits: habits)
        }
    }

    // MARK: - Sample Data Generation

    private func generateSampleLogs() {
        let calendar = Calendar.current
        let now = Date()

        for habit in habits {
            let completionChance = Double.random(in: 0.3...1.0)
            if Double.random(in: 0...1) < completionChance {
                let logCount: Int
                if habit.targetCount > 1 {
                    logCount = Int.random(in: 1...habit.targetCount)
                } else {
                    logCount = 1
                }

                for i in 0..<min(logCount, 5) {
                    let hoursAgo = Double.random(in: 1...12)
                    let logTime = now.addingTimeInterval(-hoursAgo * 3600)
                    let value: Int
                    if habit.targetCount > 5 {
                        value = habit.targetCount / Int.random(in: 2...5)
                    } else {
                        value = 1
                    }
                    let log = HabitLog(
                        habitId: habit.id,
                        completedAt: calendar.startOfDay(for: now) < logTime ? logTime : now
                            .addingTimeInterval(-Double(i) * 1800),
                        value: value
                    )
                    todayLogs.append(log)
                }
            }
        }
    }

    private func generateStreaks() {
        for habit in habits {
            streaks[habit.id] = WeeklyStreak.sample(for: habit.id)
        }
    }
}
