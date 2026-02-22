import AppIntents

// MARK: - MoodEnum

enum MoodEnum: String, AppEnum {
    case focus
    case relax
    case workout
    case commute
    case party
    case sleep

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "ムード")

    static var caseDisplayRepresentations: [MoodEnum: DisplayRepresentation] = [
        .focus: "集中モード",
        .relax: "リラックス",
        .workout: "ワークアウト",
        .commute: "通勤・通学",
        .party: "パーティー",
        .sleep: "おやすみ",
    ]

    var toMoodType: MoodType {
        switch self {
        case .focus: .focus
        case .relax: .relax
        case .workout: .workout
        case .commute: .commute
        case .party: .party
        case .sleep: .sleep
        }
    }
}

// MARK: - PlayContextualMusicIntent

struct PlayContextualMusicIntent: AppIntent {
    static var title: LocalizedStringResource = "コンテキスト再生"
    static var description = IntentDescription("現在の状況に最適な音楽を自動再生します")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = MusicContextManager.shared
        let playlist = manager.generateContextualPlaylist()
        return .result(dialog: "「\(playlist.name)」を再生します")
    }
}

// MARK: - SetMoodIntent

struct SetMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "ムードを設定"
    static var description = IntentDescription("指定したムードに合う音楽を再生します")

    @Parameter(title: "ムード")
    var mood: MoodEnum

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = MusicContextManager.shared
        let context = manager.detectCurrentContext()
        let playlist = manager.generatePlaylist(mood: mood.toMoodType, context: context)
        return .result(dialog: "「\(playlist.name)」を\(mood.toMoodType.displayName)で再生します")
    }
}
