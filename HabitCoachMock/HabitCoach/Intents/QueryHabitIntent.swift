import AppIntents

/// 今日の習慣達成状況を問い合わせる Intent
struct QueryTodayProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "今日の達成状況を確認"
    static var description = IntentDescription("今日の習慣達成状況を確認します")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = HabitManager.shared
        let completed = manager.totalCompletedToday
        let total = manager.totalHabitsCount
        let ratio = Int(manager.overallCompletionRatio * 100)

        let remaining = manager.habits.filter { !manager.isCompleted($0) }
        let remainingNames = remaining.prefix(3).map(\.name).joined(separator: "、")

        var message = "今日は \(total) 個中 \(completed) 個の習慣を達成しました（\(ratio)%）。"
        if remaining.isEmpty {
            message += "全て完了！素晴らしいです！"
        } else {
            message += "残り: \(remainingNames)"
            if remaining.count > 3 {
                message += " ほか\(remaining.count - 3)個"
            }
        }

        return .result(dialog: "\(message)")
    }
}

/// 特定の習慣のストリークを問い合わせる Intent
struct QueryStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "ストリークを確認"
    static var description = IntentDescription("習慣の連続達成日数を確認します")
    static var openAppWhenRun = false

    @Parameter(title: "習慣名")
    var habitName: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = HabitManager.shared
        if let habit = manager.habits.first(where: { $0.name == habitName }),
            let streak = manager.streak(for: habit)
        {
            return .result(
                dialog:
                    "\(habitName) は現在 \(streak.currentStreak) 日連続で達成中です。最長記録は \(streak.longestStreak) 日です。"
            )
        }
        return .result(dialog: "\(habitName) が見つかりませんでした")
    }
}
