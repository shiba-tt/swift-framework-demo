import AppIntents

struct KakeiboShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "\(.applicationName) で支出を記録",
                "\(.applicationName) に出費を追加",
            ],
            shortTitle: "支出を記録",
            systemImageName: "yensign.circle"
        )

        AppShortcut(
            intent: QuickAddExpenseIntent(),
            phrases: [
                "\(.applicationName) でかんたん記録",
                "\(.applicationName) で \(\.$inputText)",
            ],
            shortTitle: "かんたん記録",
            systemImageName: "text.badge.plus"
        )

        AppShortcut(
            intent: QueryMonthlyTotalIntent(),
            phrases: [
                "\(.applicationName) で今月いくら使った？",
                "\(.applicationName) の今月の支出は？",
            ],
            shortTitle: "今月の支出",
            systemImageName: "chart.bar"
        )

        AppShortcut(
            intent: QueryWeeklyTotalIntent(),
            phrases: [
                "\(.applicationName) で今週の支出は？",
                "\(.applicationName) で今週いくら？",
            ],
            shortTitle: "今週の支出",
            systemImageName: "calendar"
        )

        AppShortcut(
            intent: QueryCategoryTotalIntent(),
            phrases: [
                "\(.applicationName) の \(\.$category) はいくら？",
                "\(.applicationName) で \(\.$category) の支出を教えて",
            ],
            shortTitle: "カテゴリ別支出",
            systemImageName: "square.grid.2x2"
        )
    }
}
