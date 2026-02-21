import AppIntents
import AlarmKit

/// 現在のステップを完了し、次のステップのアラームを自動スケジュールする AppIntent
/// アラームの Stop ボタンタップ時にシステムから呼ばれる
struct NextStepIntent: AppIntent {
    static var title: LocalizedStringResource = "次のステップへ"
    static var description: IntentDescription = "ルーティンの次のステップに進みます"

    func perform() async throws -> some IntentResult {
        let viewModel = await RoutineViewModel.shared
        await viewModel.completeCurrentStep()
        return .result()
    }
}
