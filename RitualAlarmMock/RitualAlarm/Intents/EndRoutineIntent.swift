import AppIntents
import AlarmKit

/// ルーティン全体を終了する AppIntent
struct EndRoutineIntent: AppIntent {
    static var title: LocalizedStringResource = "ルーティンを終了"
    static var description: IntentDescription = "朝のルーティンを終了します"

    func perform() async throws -> some IntentResult {
        let viewModel = await RoutineViewModel.shared
        await viewModel.endRoutine()
        return .result()
    }
}
