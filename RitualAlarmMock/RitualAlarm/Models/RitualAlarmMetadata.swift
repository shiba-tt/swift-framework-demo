import AlarmKit
import ActivityKit

/// RitualAlarm のアラームメタデータ
/// Live Activity でのカウントダウン表示に使用
struct RitualAlarmMetadata: AlarmMetadata {
    /// 現在のステップ（RoutineStep.rawValue）
    var stepRawValue: String
    /// 全ステップ数
    var totalSteps: Int
    /// 現在のステップインデックス（0始まり）
    var currentStepIndex: Int

    var step: RoutineStep {
        RoutineStep(rawValue: stepRawValue) ?? .wakeUp
    }

    // MARK: - AlarmActivityConfiguration

    nonisolated static var activityConfiguration: some AlarmActivityConfiguration {
        ActivityConfiguration(for: AlarmAttributes<RitualAlarmMetadata>.self) { context in
            // ロック画面 / StandBy 表示
            RitualAlarmLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.attributes.metadata.step.label)
                    } icon: {
                        Image(systemName: context.attributes.metadata.step.systemImageName)
                    }
                    .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.attributes.metadata.currentStepIndex + 1)/\(context.attributes.metadata.totalSteps)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isCountingDown {
                        Text("ルーティン進行中...")
                            .font(.caption)
                    } else {
                        Text(context.attributes.metadata.step.alertSubtitle)
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.metadata.step.systemImageName)
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text(context.attributes.metadata.step.emoji)
                    .font(.caption2)
            } minimal: {
                Image(systemName: context.attributes.metadata.step.systemImageName)
                    .foregroundStyle(.orange)
            }
        }
    }
}
