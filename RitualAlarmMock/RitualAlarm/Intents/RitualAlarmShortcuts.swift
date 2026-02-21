import AppIntents

/// RitualAlarm の AppShortcuts 定義
/// Siri / Shortcuts アプリからアクセス可能
struct RitualAlarmShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextStepIntent(),
            phrases: [
                "朝のルーティンを開始",
                "\(.applicationName) でルーティンを始める",
                "\(.applicationName) で朝の準備"
            ],
            shortTitle: "ルーティン開始",
            systemImageName: "alarm.fill"
        )
    }
}
