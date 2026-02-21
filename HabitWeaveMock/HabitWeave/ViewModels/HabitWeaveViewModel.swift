import Foundation
import SwiftUI

/// HabitWeave アプリのメイン ViewModel
@MainActor
@Observable
final class HabitWeaveViewModel {

    // MARK: - State

    private(set) var habits: [Habit] = []
    private(set) var records: [HabitRecord] = []
    private(set) var weeklyProgress: WeeklyProgress?
    private(set) var isLoading = false
    private(set) var calendarAccessGranted = false

    // MARK: - Dependencies

    private let scheduleManager = HabitScheduleManager.shared

    // MARK: - Computed Properties

    /// アクティブな習慣
    var activeHabits: [Habit] {
        habits.filter { $0.isActive }
    }

    /// 非アクティブな習慣
    var inactiveHabits: [Habit] {
        habits.filter { !$0.isActive }
    }

    /// 今日のカレンダーイベント
    var todayEvents: [CalendarEvent] {
        scheduleManager.calendarEvents
    }

    /// 空き時間スロット
    var freeTimeSlots: [FreeTimeSlot] {
        scheduleManager.freeTimeSlots
    }

    /// スケジュールされた習慣
    var scheduledHabits: [ScheduledHabit] {
        scheduleManager.scheduledHabits
    }

    /// 今日の完了率
    var todayCompletionRate: Double {
        let todayRecords = records.filter {
            Calendar.current.isDateInToday($0.date)
        }
        guard !todayRecords.isEmpty else { return 0 }
        let completed = todayRecords.filter { $0.isCompleted }.count
        return Double(completed) / Double(todayRecords.count)
    }

    /// 今日の完了率テキスト
    var todayCompletionRateText: String {
        "\(Int(todayCompletionRate * 100))%"
    }

    /// 今日の完了数 / 総数テキスト
    var todayProgressText: String {
        let todayRecords = records.filter {
            Calendar.current.isDateInToday($0.date)
        }
        let completed = todayRecords.filter { $0.isCompleted }.count
        return "\(completed)/\(todayRecords.count)"
    }

    /// 連続達成日数
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let dayRecords = records.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            guard !dayRecords.isEmpty else { break }
            let allCompleted = dayRecords.allSatisfy { $0.isCompleted }
            if allCompleted {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }

    /// 合計空き時間（分）
    var totalFreeMinutes: Int {
        freeTimeSlots.reduce(0) { $0 + $1.durationMinutes }
    }

    /// 合計空き時間テキスト
    var totalFreeTimeText: String {
        let hours = totalFreeMinutes / 60
        let mins = totalFreeMinutes % 60
        if hours > 0 {
            return "\(hours)時間\(mins)分"
        }
        return "\(mins)分"
    }

    // MARK: - Actions

    /// アプリ起動時の初期化
    func initialize() async {
        isLoading = true

        // カレンダーアクセス
        calendarAccessGranted = await scheduleManager.requestCalendarAccess()

        // モックデータ読み込み
        habits = Habit.samples
        scheduleManager.loadTodayEvents()
        scheduleManager.scheduleHabits(habits)
        records = scheduleManager.generateMockRecords(for: habits)
        weeklyProgress = scheduleManager.generateMockWeeklyProgress()

        // Widget 用データ保存
        scheduleManager.saveForWidget(habits: habits, completionRate: todayCompletionRate)

        isLoading = false
    }

    /// 習慣の完了をトグルする
    func toggleCompletion(for habit: Habit) {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = records.firstIndex(where: {
            $0.habitID == habit.id && Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            let old = records[index]
            records[index] = HabitRecord(
                id: old.id,
                habitID: old.habitID,
                date: old.date,
                isCompleted: !old.isCompleted,
                scheduledStartTime: old.scheduledStartTime,
                actualDurationMinutes: !old.isCompleted ? habit.durationMinutes : nil,
                note: old.note
            )
        } else {
            records.insert(HabitRecord(
                id: UUID(),
                habitID: habit.id,
                date: today,
                isCompleted: true,
                scheduledStartTime: Date(),
                actualDurationMinutes: habit.durationMinutes,
                note: nil
            ), at: 0)
        }

        scheduleManager.saveForWidget(habits: habits, completionRate: todayCompletionRate)
    }

    /// 習慣の有効/無効を切り替える
    func toggleActive(for habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isActive.toggle()
            scheduleManager.scheduleHabits(habits)
        }
    }

    /// 習慣が今日完了済みかどうか
    func isCompletedToday(_ habit: Habit) -> Bool {
        records.contains {
            $0.habitID == habit.id
            && Calendar.current.isDateInToday($0.date)
            && $0.isCompleted
        }
    }

    /// 習慣の今週の完了回数
    func weeklyCompletionCount(for habit: Habit) -> Int {
        let calendar = Calendar.current
        let weekStart = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date()))!
        return records.filter {
            $0.habitID == habit.id
            && $0.date >= weekStart
            && $0.isCompleted
        }.count
    }
}
