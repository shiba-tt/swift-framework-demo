import AppIntents

/// FocusForge の AppShortcuts 定義
/// Siri / Shortcuts アプリからアクセス可能
struct FocusForgeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartWorkIntent(),
            phrases: [
                "ポモドーロを開始",
                "\(.applicationName) で作業を始める",
                "\(.applicationName) で集中モード"
            ],
            shortTitle: "ポモドーロ開始",
            systemImageName: "brain.head.profile"
        )
    }
}
