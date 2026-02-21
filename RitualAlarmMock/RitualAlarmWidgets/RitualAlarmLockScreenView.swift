import SwiftUI
import AlarmKit
import ActivityKit

/// ロック画面 / StandBy に表示される Live Activity ビュー
struct RitualAlarmLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<RitualAlarmMetadata>>

    private var metadata: RitualAlarmMetadata {
        context.attributes.metadata
    }

    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー: ステップ進捗
            HStack {
                Image(systemName: metadata.step.systemImageName)
                    .font(.title2)
                    .foregroundStyle(.orange)

                Text(metadata.step.label)
                    .font(.title3.bold())

                Spacer()

                Text("\(metadata.currentStepIndex + 1)/\(metadata.totalSteps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // ステップ進捗バー
            HStack(spacing: 4) {
                ForEach(0..<metadata.totalSteps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor(for: index))
                        .frame(height: 6)
                }
            }

            // カウントダウン or アラート表示
            if context.state.isCountingDown {
                VStack(spacing: 4) {
                    Text("残り時間")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(timerInterval: context.state.countdownRange, countsDown: true)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundStyle(.orange)
                }
            } else {
                VStack(spacing: 8) {
                    Text(metadata.step.alertTitle)
                        .font(.title2.bold())

                    Text(metadata.step.alertSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    private func barColor(for index: Int) -> Color {
        if index < metadata.currentStepIndex {
            return .green
        } else if index == metadata.currentStepIndex {
            return .orange
        } else {
            return .white.opacity(0.2)
        }
    }
}
