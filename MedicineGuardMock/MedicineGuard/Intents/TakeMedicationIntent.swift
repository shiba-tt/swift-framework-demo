import AppIntents
import AlarmKit

/// 服薬完了を記録する AppIntent
/// アラームの Stop ボタン（"服用済み"）タップ時にシステムから呼ばれる
struct TakeMedicationIntent: AppIntent {
    static var title: LocalizedStringResource = "服薬を記録"
    static var description: IntentDescription = "薬の服用を記録します"

    func perform() async throws -> some IntentResult {
        let viewModel = await MedicationViewModel.shared
        await viewModel.recordCurrentMedicationTaken()
        return .result()
    }
}
