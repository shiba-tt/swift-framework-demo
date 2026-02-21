import AlarmKit
import ActivityKit

/// SleepCraft のアラームメタデータ
/// Live Activity でのカウントダウン・睡眠ステージ表示に使用
struct SleepCraftAlarmMetadata: AlarmMetadata {
    /// 起床希望時刻のタイムスタンプ
    var targetWakeUpTimestamp: Double
    /// スマートウィンドウ開始時刻のタイムスタンプ
    var windowStartTimestamp: Double
    /// 睡眠スコア
    var sleepScore: Int
    /// スマートアラームで起こされたか
    var isSmartWakeUp: Bool

    var targetWakeUpTime: Date {
        Date(timeIntervalSince1970: targetWakeUpTimestamp)
    }

    var windowStartTime: Date {
        Date(timeIntervalSince1970: windowStartTimestamp)
    }

    // MARK: - AlarmActivityConfiguration

    nonisolated static var activityConfiguration: some AlarmActivityConfiguration {
        ActivityConfiguration(for: AlarmAttributes<SleepCraftAlarmMetadata>.self) { context in
            // ロック画面 / StandBy 表示
            SleepCraftLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text("SleepCraft")
                    } icon: {
                        Image(systemName: "bed.double.fill")
                    }
                    .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.attributes.metadata.isSmartWakeUp {
                        Label("スマート", systemImage: "brain.head.profile.fill")
                            .font(.caption)
                            .foregroundStyle(.cyan)
                    } else {
                        Label("通常", systemImage: "alarm.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isCountingDown {
                        Text("睡眠モニタリング中...")
                            .font(.caption)
                    } else {
                        let score = context.attributes.metadata.sleepScore
                        Text("睡眠スコア: \(score)/100")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Image(systemName: "moon.zzz.fill")
                    .foregroundStyle(.indigo)
            } compactTrailing: {
                Image(systemName: "bed.double.fill")
                    .font(.caption2)
            } minimal: {
                Image(systemName: "moon.zzz.fill")
                    .foregroundStyle(.indigo)
            }
        }
    }
}
