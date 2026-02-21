import AlarmKit
import ActivityKit

/// MedicineGuard のアラームメタデータ
/// Live Activity での服薬リマインダー表示に使用
struct MedicineAlarmMetadata: AlarmMetadata {
    /// 薬の名前
    var medicationName: String
    /// 用量
    var dosage: String
    /// カテゴリ（MedicationCategory.rawValue）
    var categoryRawValue: String
    /// スケジュール説明
    var scheduleDescription: String

    var category: MedicationCategory {
        MedicationCategory(rawValue: categoryRawValue) ?? .prescription
    }

    // MARK: - AlarmActivityConfiguration

    nonisolated static var activityConfiguration: some AlarmActivityConfiguration {
        ActivityConfiguration(for: AlarmAttributes<MedicineAlarmMetadata>.self) { context in
            // ロック画面 / StandBy 表示
            MedicineGuardLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.attributes.metadata.medicationName)
                    } icon: {
                        Image(systemName: context.attributes.metadata.category.systemImageName)
                    }
                    .font(.headline)
                    .foregroundStyle(.blue)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.metadata.dosage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isCountingDown {
                        Text("次の服薬まで...")
                            .font(.caption)
                    } else {
                        Text("💊 服薬の時間です")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.metadata.category.systemImageName)
                    .foregroundStyle(.blue)
            } compactTrailing: {
                Text(context.attributes.metadata.category.emoji)
                    .font(.caption2)
            } minimal: {
                Image(systemName: "pills.fill")
                    .foregroundStyle(.blue)
            }
        }
    }
}
