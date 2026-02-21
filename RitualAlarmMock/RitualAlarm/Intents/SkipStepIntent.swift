import AppIntents
import AlarmKit

/// 現在のステップをスキップして次へ進む AppIntent
/// アラームの Secondary ボタンタップ時にシステムから呼ばれる
struct SkipStepIntent: AppIntent {
    static var title: LocalizedStringResource = "ステップをスキップ"
    static var description: IntentDescription = "現在のステップをスキップして次に進みます"

    func perform() async throws -> some IntentResult {
        let viewModel = await RoutineViewModel.shared
        await viewModel.skipCurrentStep()
        return .result()
    }
}
