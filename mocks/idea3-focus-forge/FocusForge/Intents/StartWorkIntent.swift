import AppIntents
import AlarmKit

/// 休憩フェーズ完了後に作業タイマーを自動開始する AppIntent
/// アラームの Stop ボタンタップ時にシステムから呼ばれる
struct StartWorkIntent: AppIntent {
    static var title: LocalizedStringResource = "作業を開始"
    static var description: IntentDescription = "休憩フェーズの完了後に作業タイマーを開始します"

    func perform() async throws -> some IntentResult {
        let viewModel = await PomodoroViewModel.shared
        await viewModel.transitionToWork()
        return .result()
    }
}
