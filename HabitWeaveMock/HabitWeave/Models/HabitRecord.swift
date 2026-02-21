import Foundation

/// 習慣の実行記録
struct HabitRecord: Identifiable, Sendable {
    let id: UUID
    let habitID: UUID
    let date: Date
    let isCompleted: Bool
    let scheduledStartTime: Date
    let actualDurationMinutes: Int?
    let note: String?

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 時刻テキスト
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: scheduledStartTime)
    }
}

// MARK: - FreeTimeSlot

/// カレンダーの空き時間スロット
struct FreeTimeSlot: Identifiable, Sendable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let durationMinutes: Int

    /// 時間帯テキスト
    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    /// 所要時間テキスト
    var durationText: String {
        if durationMinutes >= 60 {
            let hours = durationMinutes / 60
            let mins = durationMinutes % 60
            return mins > 0 ? "\(hours)時間\(mins)分" : "\(hours)時間"
        }
        return "\(durationMinutes)分"
    }
}

// MARK: - ScheduledHabit

/// カレンダーに配置された習慣
struct ScheduledHabit: Identifiable, Sendable {
    let id: UUID
    let habit: Habit
    let scheduledTime: Date
    let freeSlot: FreeTimeSlot

    /// 開始時刻テキスト
    var startTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: scheduledTime)
    }

    /// 終了時刻テキスト
    var endTimeText: String {
        let endTime = scheduledTime.addingTimeInterval(Double(habit.durationMinutes) * 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: endTime)
    }
}

// MARK: - WeeklyProgress

/// 週間の進捗データ
struct WeeklyProgress: Sendable {
    let weekStartDate: Date
    let dailyRecords: [DayProgress]
    let overallCompletionRate: Double

    /// 完了率テキスト
    var completionRateText: String {
        let percent = Int(overallCompletionRate * 100)
        return "\(percent)%"
    }
}

/// 日別の進捗
struct DayProgress: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let totalHabits: Int
    let completedHabits: Int

    /// 曜日テキスト
    var dayOfWeekText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 完了率
    var completionRate: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completedHabits) / Double(totalHabits)
    }
}
