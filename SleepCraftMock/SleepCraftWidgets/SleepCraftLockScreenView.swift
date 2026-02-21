import SwiftUI
import AlarmKit
import ActivityKit

/// ロック画面 / StandBy 用の Live Activity 表示
struct SleepCraftLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<SleepCraftAlarmMetadata>>

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "moon.zzz.fill")
                    .font(.title2)
                    .foregroundStyle(.indigo)

                Text("SleepCraft")
                    .font(.headline)

                Spacer()

                if context.attributes.metadata.isSmartWakeUp {
                    Label("スマート", systemImage: "brain.head.profile.fill")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                }
            }

            if context.state.isCountingDown {
                // 睡眠モニタリング中
                VStack(spacing: 8) {
                    Text("睡眠モニタリング中")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 20) {
                        VStack {
                            Text("アラーム")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(context.attributes.metadata.targetWakeUpTime, style: .time)
                                .font(.title3)
                                .fontWeight(.medium)
                        }

                        Divider()
                            .frame(height: 30)

                        VStack {
                            Text("スコア")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(context.attributes.metadata.sleepScore)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.indigo)
                        }
                    }
                }
            } else {
                // アラート表示
                VStack(spacing: 4) {
                    Text("おはようございます")
                        .font(.title3)
                        .fontWeight(.medium)

                    if context.attributes.metadata.isSmartWakeUp {
                        Text("浅い睡眠のタイミングで起こしました")
                            .font(.caption)
                            .foregroundStyle(.cyan)
                    }

                    Text("睡眠スコア: \(context.attributes.metadata.sleepScore)/100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
