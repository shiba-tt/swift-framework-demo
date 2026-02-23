import AppIntents

/// App Shortcuts Provider
struct VoiceRecipeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextStepIntent(),
            phrases: [
                "\(.applicationName) 次のステップ",
                "\(.applicationName) 次",
            ],
            shortTitle: "次のステップ",
            systemImageName: "forward.fill"
        )

        AppShortcut(
            intent: RepeatStepIntent(),
            phrases: [
                "\(.applicationName) もう一回",
                "\(.applicationName) 繰り返して",
            ],
            shortTitle: "もう一回",
            systemImageName: "arrow.counterclockwise"
        )

        AppShortcut(
            intent: StartTimerIntent(),
            phrases: [
                "\(.applicationName) タイマー開始",
                "\(.applicationName) タイマーセット",
            ],
            shortTitle: "タイマー",
            systemImageName: "timer"
        )

        AppShortcut(
            intent: SearchRecipeIntent(),
            phrases: [
                "\(.applicationName) でレシピを探して",
            ],
            shortTitle: "レシピ検索",
            systemImageName: "magnifyingglass"
        )
    }
}
