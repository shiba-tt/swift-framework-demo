import Foundation

/// 習慣のスケジューリングとカレンダー連携を管理するマネージャー
@MainActor
@Observable
final class HabitScheduleManager {

    // MARK: - Singleton

    static let shared = HabitScheduleManager()
    private init() {}

    // MARK: - Constants

    private let appGroupID = "group.com.example.habitweave"

    // MARK: - State

    private(set) var calendarEvents: [CalendarEvent] = []
    private(set) var freeTimeSlots: [FreeTimeSlot] = []
    private(set) var scheduledHabits: [ScheduledHabit] = []
    private(set) var calendarAccessGranted = false

    // MARK: - Data Access

    /// App Group の UserDefaults
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Calendar Access

    /// カレンダーアクセス権限をリクエストする（モック）
    func requestCalendarAccess() async -> Bool {
        // モックでは常に許可とする
        calendarAccessGranted = true
        return true
    }

    // MARK: - Event Loading

    /// 今日のカレンダーイベントを読み込む（モック）
    func loadTodayEvents() {
        calendarEvents = CalendarEvent.samples
        calculateFreeSlots()
    }

    /// 空き時間スロットを計算する
    private func calculateFreeSlots() {
        let today = Calendar.current.startOfDay(for: Date())
        let sortedEvents = calendarEvents
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }

        var slots: [FreeTimeSlot] = []
        var currentTime = today.addingTimeInterval(7 * 3600) // 7:00 開始

        for event in sortedEvents {
            let gap = event.startDate.timeIntervalSince(currentTime)
            if gap >= 15 * 60 { // 15分以上の空きがあれば
                slots.append(FreeTimeSlot(
                    id: UUID(),
                    startTime: currentTime,
                    endTime: event.startDate,
                    durationMinutes: Int(gap / 60)
                ))
            }
            currentTime = event.endDate
        }

        // 最後のイベント後〜22:00 までの空き
        let endOfDay = today.addingTimeInterval(22 * 3600)
        let remainingGap = endOfDay.timeIntervalSince(currentTime)
        if remainingGap >= 15 * 60 {
            slots.append(FreeTimeSlot(
                id: UUID(),
                startTime: currentTime,
                endTime: endOfDay,
                durationMinutes: Int(remainingGap / 60)
            ))
        }

        freeTimeSlots = slots
    }

    // MARK: - Habit Scheduling

    /// 習慣を空き時間に自動配置する
    func scheduleHabits(_ habits: [Habit]) {
        var scheduled: [ScheduledHabit] = []
        var usedSlots: [UUID: Int] = [:] // slotID -> 使用済み分数

        let activeHabits = habits.filter { $0.isActive }
            .sorted { $0.durationMinutes > $1.durationMinutes } // 長い習慣から配置

        for habit in activeHabits {
            if let (slot, startTime) = findBestSlot(for: habit, usedSlots: &usedSlots) {
                scheduled.append(ScheduledHabit(
                    id: UUID(),
                    habit: habit,
                    scheduledTime: startTime,
                    freeSlot: slot
                ))
            }
        }

        scheduledHabits = scheduled.sorted { $0.scheduledTime < $1.scheduledTime }
    }

    /// 習慣に最適な空き時間スロットを見つける
    private func findBestSlot(
        for habit: Habit,
        usedSlots: inout [UUID: Int]
    ) -> (FreeTimeSlot, Date)? {
        let calendar = Calendar.current

        // 希望時間帯のスロットを優先
        let preferredSlots = freeTimeSlots.filter { slot in
            let hour = calendar.component(.hour, from: slot.startTime)
            return habit.preferredTimeSlot.hourRange.contains(hour)
        }

        let candidates = preferredSlots.isEmpty ? freeTimeSlots : preferredSlots

        for slot in candidates {
            let usedMinutes = usedSlots[slot.id] ?? 0
            let availableMinutes = slot.durationMinutes - usedMinutes

            if availableMinutes >= habit.durationMinutes {
                let startTime = slot.startTime.addingTimeInterval(Double(usedMinutes) * 60)
                usedSlots[slot.id] = usedMinutes + habit.durationMinutes
                return (slot, startTime)
            }
        }

        return nil
    }

    // MARK: - Persistence

    /// 習慣データを Widget 向けに保存する
    func saveForWidget(habits: [Habit], completionRate: Double) {
        let defaults = sharedDefaults
        defaults?.set(habits.filter { $0.isActive }.count, forKey: "activeHabitCount")
        defaults?.set(completionRate, forKey: "completionRate")
        defaults?.set(scheduledHabits.count, forKey: "scheduledCount")

        // 次のスケジュール情報
        if let next = scheduledHabits.first(where: { $0.scheduledTime > Date() }) {
            defaults?.set(next.habit.title, forKey: "nextHabitTitle")
            defaults?.set(next.habit.category.emoji, forKey: "nextHabitEmoji")
            defaults?.set(next.startTimeText, forKey: "nextHabitTime")
        }
    }

    // MARK: - Mock Data

    /// デモ用の週間進捗を生成する
    func generateMockWeeklyProgress() -> WeeklyProgress {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today)!

        let dailyRecords = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
            let total = Int.random(in: 3...5)
            let completed = min(total, Int.random(in: 1...total))
            return DayProgress(
                id: UUID(),
                date: date,
                totalHabits: total,
                completedHabits: completed
            )
        }

        let totalHabits = dailyRecords.reduce(0) { $0 + $1.totalHabits }
        let completedHabits = dailyRecords.reduce(0) { $0 + $1.completedHabits }
        let rate = totalHabits > 0 ? Double(completedHabits) / Double(totalHabits) : 0

        return WeeklyProgress(
            weekStartDate: weekStart,
            dailyRecords: dailyRecords,
            overallCompletionRate: rate
        )
    }

    /// デモ用のレコードを生成する
    func generateMockRecords(for habits: [Habit]) -> [HabitRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var records: [HabitRecord] = []
        for habit in habits where habit.isActive {
            for dayOffset in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
                let isCompleted = Bool.random() || dayOffset < 2
                let hour = habit.preferredTimeSlot.hourRange.lowerBound + Int.random(in: 0...2)
                let scheduledTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)!

                records.append(HabitRecord(
                    id: UUID(),
                    habitID: habit.id,
                    date: date,
                    isCompleted: isCompleted,
                    scheduledStartTime: scheduledTime,
                    actualDurationMinutes: isCompleted ? habit.durationMinutes + Int.random(in: -5...5) : nil,
                    note: nil
                ))
            }
        }

        return records.sorted { $0.date > $1.date }
    }
}
