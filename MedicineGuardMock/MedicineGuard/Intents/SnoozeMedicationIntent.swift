import AppIntents
import AlarmKit

/// 服薬リマインダーをスヌーズする AppIntent
/// アラームの Secondary ボタン（"30分後"）タップ時にシステムから呼ばれる
struct SnoozeMedicationIntent: AppIntent {
    static var title: LocalizedStringResource = "服薬をスヌーズ"
    static var description: IntentDescription = "服薬リマインダーを後で再通知します"

    func perform() async throws -> some IntentResult {
        let viewModel = await MedicationViewModel.shared
        await viewModel.snoozeCurrentMedication()
        return .result()
    }
}
