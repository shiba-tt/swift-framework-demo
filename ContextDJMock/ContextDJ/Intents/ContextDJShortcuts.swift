import AppIntents

struct ContextDJShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlayContextualMusicIntent(),
            phrases: [
                "\(.applicationName) で音楽をかけて",
                "\(.applicationName) のコンテキスト再生",
                "今の状況に合う音楽を \(.applicationName) でかけて",
            ],
            shortTitle: "コンテキスト再生",
            systemImageName: "music.note"
        )
        AppShortcut(
            intent: SetMoodIntent(),
            phrases: [
                "\(.applicationName) で集中できる音楽をかけて",
                "\(.applicationName) でリラックスする音楽",
                "\(.applicationName) のムード設定",
            ],
            shortTitle: "ムード設定",
            systemImageName: "slider.horizontal.3"
        )
    }
}
