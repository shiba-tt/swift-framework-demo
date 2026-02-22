import AppIntents

struct FlashCardShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickStudyIntent(),
            phrases: [
                "\(.applicationName) で問題を出して",
                "\(.applicationName) のクイック学習",
                "\(.applicationName) で暗記カード",
            ],
            shortTitle: "クイック学習",
            systemImageName: "brain.head.profile"
        )
        AppShortcut(
            intent: QueryStudyStatsIntent(),
            phrases: [
                "\(.applicationName) の学習状況",
                "今日覚えた単語は何個？",
                "\(.applicationName) で統計を見せて",
            ],
            shortTitle: "学習統計",
            systemImageName: "chart.bar"
        )
        AppShortcut(
            intent: QueryDueCardsIntent(),
            phrases: [
                "\(.applicationName) の残り復習数",
                "復習するカードはある？",
            ],
            shortTitle: "残り復習数",
            systemImageName: "rectangle.stack"
        )
    }
}
