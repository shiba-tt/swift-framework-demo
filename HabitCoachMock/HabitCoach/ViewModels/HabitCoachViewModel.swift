import Foundation
import SwiftUI

@MainActor
@Observable
final class HabitCoachViewModel {
    // MARK: - Tab

    enum Tab: String, Sendable {
        case today
        case habits
        case insights
    }

    var selectedTab: Tab = .today

    // MARK: - UI State

    var showingAddHabit = false

    // MARK: - Dependencies

    private let manager = HabitManager.shared

    // MARK: - Proxied State

    var habits: [Habit] { manager.habits }
    var todayLogs: [HabitLog] { manager.todayLogs }
    var suggestions: [SiriSuggestion] { manager.suggestions }

    var totalCompletedToday: Int { manager.totalCompletedToday }
    var totalHabitsCount: Int { manager.totalHabitsCount }
    var overallCompletionRatio: Double { manager.overallCompletionRatio }

    var habitsByCategory: [(category: HabitCategory, habits: [Habit])] {
        manager.habitsByCategory
    }

    // MARK: - Actions

    func logHabit(_ habit: Habit, value: Int = 1) {
        withAnimation(.spring(duration: 0.3)) {
            manager.logHabit(habit, value: value)
        }
    }

    func dismissSuggestion(_ suggestion: SiriSuggestion) {
        withAnimation {
            manager.dismissSuggestion(suggestion)
        }
    }

    // MARK: - Query

    func todayProgress(for habit: Habit) -> Int {
        manager.todayProgress(for: habit)
    }

    func isCompleted(_ habit: Habit) -> Bool {
        manager.isCompleted(habit)
    }

    func completionRatio(for habit: Habit) -> Double {
        manager.completionRatio(for: habit)
    }

    func streak(for habit: Habit) -> WeeklyStreak? {
        manager.streak(for: habit)
    }
}
