import AppIntents
import AlarmKit

/// 作業フェーズ完了後に休憩タイマーを自動開始する AppIntent
/// アラームの Stop ボタンタップ時にシステムから呼ばれる
struct StartBreakIntent: AppIntent {
    static var title: LocalizedStringResource = "休憩を開始"
    static var description: IntentDescription = "作業フェーズの完了後に休憩タイマーを開始します"

    func perform() async throws -> some IntentResult {
        let viewModel = await PomodoroViewModel.shared
        await viewModel.transitionToBreak()
        return .result()
    }
}
