import SwiftUI
import AlarmKit
import ActivityKit

/// ロック画面 / StandBy に表示される Live Activity ビュー
struct FocusForgeLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<FocusForgeAlarmMetadata>>

    private var metadata: FocusForgeAlarmMetadata {
        context.attributes.metadata
    }

    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                Image(systemName: metadata.phase.systemImageName)
                    .font(.title2)
                    .foregroundStyle(metadata.phase == .work ? .orange : .green)

                Text(metadata.phase.label)
                    .font(.title3.bold())

                Spacer()

                Text("\(metadata.completedCount)/\(metadata.dailyGoal)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // カウントダウン表示
            if context.state.isCountingDown {
                VStack(spacing: 4) {
                    Text("残り時間")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // AlarmKit が自動的にカウントダウンを管理
                    Text(timerInterval: context.state.countdownRange, countsDown: true)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundStyle(metadata.phase == .work ? .orange : .green)
                }
            } else {
                // アラート状態
                VStack(spacing: 8) {
                    Text(metadata.phase == .work ? "お疲れさまでした！" : "さあ、始めましょう！")
                        .font(.title2.bold())

                    Text(metadata.phase.alertSubtitle(completedCount: metadata.completedCount))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // ポモドーロ進捗ドット
            HStack(spacing: 6) {
                ForEach(0..<metadata.dailyGoal, id: \.self) { index in
                    Circle()
                        .fill(index < metadata.completedCount ? Color.orange : Color.white.opacity(0.2))
                        .frame(width: 10, height: 10)
                }
            }
        }
        .padding()
    }
}
