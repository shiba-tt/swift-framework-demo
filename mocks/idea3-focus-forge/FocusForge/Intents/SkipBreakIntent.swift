import AppIntents
import AlarmKit

/// 休憩をスキップして作業タイマーを直接開始する AppIntent
/// アラームの Secondary ボタンタップ時にシステムから呼ばれる
struct SkipBreakIntent: AppIntent {
    static var title: LocalizedStringResource = "休憩をスキップ"
    static var description: IntentDescription = "休憩をスキップして次の作業フェーズを開始します"

    func perform() async throws -> some IntentResult {
        let viewModel = await PomodoroViewModel.shared
        await viewModel.transitionToWork()
        return .result()
    }
}
