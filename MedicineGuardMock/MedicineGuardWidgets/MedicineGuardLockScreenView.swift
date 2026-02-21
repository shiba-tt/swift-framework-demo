import SwiftUI
import AlarmKit
import ActivityKit

/// ロック画面 / StandBy に表示される Live Activity ビュー
struct MedicineGuardLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<MedicineAlarmMetadata>>

    private var metadata: MedicineAlarmMetadata {
        context.attributes.metadata
    }

    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                Image(systemName: metadata.category.systemImageName)
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text(metadata.medicationName)
                    .font(.title3.bold())

                Spacer()

                Text(metadata.dosage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // メイン表示
            if context.state.isCountingDown {
                // スヌーズカウントダウン
                VStack(spacing: 8) {
                    Text("次のリマインドまで")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(timerInterval: context.state.countdownRange, countsDown: true)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundStyle(.blue)

                    Text(metadata.scheduleDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                // アラート状態
                VStack(spacing: 12) {
                    Text(metadata.category.emoji)
                        .font(.system(size: 60))

                    Text("服薬の時間です")
                        .font(.title2.bold())

                    Text("\(metadata.medicationName) \(metadata.dosage)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // フッター
            HStack {
                Image(systemName: "bell.slash.fill")
                    .font(.caption)
                Text("サイレントモードでも通知されます")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}
