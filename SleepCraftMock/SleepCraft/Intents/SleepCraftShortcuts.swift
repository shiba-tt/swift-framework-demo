import AppIntents

/// SleepCraft のショートカット定義
struct SleepCraftShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: WakeUpIntent(),
            phrases: [
                "起きる",
                "\(.applicationName)を止めて",
                "\(.applicationName)のアラームを止めて"
            ],
            shortTitle: "起床",
            systemImageName: "sun.max.fill"
        )
    }
}
