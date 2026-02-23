import AppIntents

/// HabitCoach の App Shortcuts プロバイダ
struct HabitCoachShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogHabitIntent(),
            phrases: [
                "\(.applicationName) で習慣を記録",
                "\(.applicationName) で \(\.$habitName)",
                "\(.applicationName) で水を飲んだ",
                "\(.applicationName) でストレッチ完了",
                "\(.applicationName) で瞑想を始めて",
            ],
            shortTitle: "習慣を記録",
            systemImageName: "checkmark.circle"
        )

        AppShortcut(
            intent: QueryTodayProgressIntent(),
            phrases: [
                "\(.applicationName) の今日の進捗",
                "\(.applicationName) で今日いくつ達成した？",
                "\(.applicationName) の達成状況は？",
            ],
            shortTitle: "今日の達成状況",
            systemImageName: "chart.pie"
        )

        AppShortcut(
            intent: QueryStreakIntent(),
            phrases: [
                "\(.applicationName) のストリークを確認",
                "\(.applicationName) で \(\.$habitName) は何日連続？",
            ],
            shortTitle: "ストリーク確認",
            systemImageName: "flame"
        )
    }
}
