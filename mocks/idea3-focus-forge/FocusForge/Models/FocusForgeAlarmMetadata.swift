import AlarmKit
import ActivityKit

/// FocusForge のアラームメタデータ
/// Live Activity でのカウントダウン表示に使用
struct FocusForgeAlarmMetadata: AlarmMetadata {
    /// 現在のフェーズ（"work" / "shortBreak" / "longBreak"）
    var phaseRawValue: String
    /// 完了済みポモドーロ数
    var completedCount: Int
    /// 1日の目標ポモドーロ数
    var dailyGoal: Int

    var phase: PomodoroPhase {
        PomodoroPhase(rawValue: phaseRawValue) ?? .work
    }

    // MARK: - AlarmActivityConfiguration

    nonisolated static var activityConfiguration: some AlarmActivityConfiguration {
        ActivityConfiguration(for: AlarmAttributes<FocusForgeAlarmMetadata>.self) { context in
            // ロック画面 / StandBy 表示
            FocusForgeLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.attributes.metadata.phase.label)
                    } icon: {
                        Image(systemName: context.attributes.metadata.phase.systemImageName)
                    }
                    .font(.headline)
                    .foregroundStyle(context.attributes.metadata.phase == .work ? .orange : .green)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.attributes.metadata.completedCount)/\(context.attributes.metadata.dailyGoal)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isCountingDown {
                        Text("カウントダウン中...")
                            .font(.caption)
                    } else {
                        Text(context.attributes.metadata.phase == .work ? "休憩しましょう" : "作業を再開しましょう")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.metadata.phase.systemImageName)
                    .foregroundStyle(context.attributes.metadata.phase == .work ? .orange : .green)
            } compactTrailing: {
                Text(context.attributes.metadata.phase.label)
                    .font(.caption2)
            } minimal: {
                Image(systemName: context.attributes.metadata.phase.systemImageName)
                    .foregroundStyle(context.attributes.metadata.phase == .work ? .orange : .green)
            }
        }
    }
}
