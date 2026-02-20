import AppIntents
import AlarmKit

/// ポモドーロセッションを終了する AppIntent
/// アラームの「終了」ボタンタップ時にシステムから呼ばれる
struct EndSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "セッションを終了"
    static var description: IntentDescription = "現在のポモドーロセッションを終了します"

    func perform() async throws -> some IntentResult {
        let viewModel = await PomodoroViewModel.shared
        await viewModel.endSession()
        return .result()
    }
}
