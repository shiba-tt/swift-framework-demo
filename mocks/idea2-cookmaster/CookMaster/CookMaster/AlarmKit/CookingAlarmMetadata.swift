import AlarmKit
import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - 料理タイマー用 AlarmMetadata

/// AlarmKit の Live Activity 表示に使用するメタデータ
struct CookingAlarmMetadata: AlarmMetadata {
    /// タイマー名（例: "パスタ茹で"）
    var timerName: String
    /// カテゴリの生値（Codable のため String で保持）
    var categoryRawValue: String
    /// カテゴリの絵文字
    var emoji: String

    var category: CookingCategory {
        CookingCategory(rawValue: categoryRawValue) ?? .custom
    }

    init(timerName: String, category: CookingCategory) {
        self.timerName = timerName
        self.categoryRawValue = category.rawValue
        self.emoji = category.emoji
    }

    // MARK: - Live Activity Configuration

    nonisolated static var activityConfiguration: some AlarmActivityConfiguration {
        ActivityConfiguration(for: AlarmAttributes<CookingAlarmMetadata>.self) { context in
            // MARK: ロック画面 / StandBy / バナー表示
            CookingTimerLockScreenView(context: context)
        } dynamicIsland: { context in
            // MARK: Dynamic Island 表示
            DynamicIsland {
                // 展開時
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Text(context.attributes.metadata.emoji)
                            .font(.title2)
                        Text(context.attributes.metadata.timerName)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isCountingDown {
                        Text("カウントダウン中")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("完了!")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .bold()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isCountingDown {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                            Text("残り時間")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("\(context.attributes.metadata.timerName)が完了しました!")
                            .font(.subheadline)
                            .bold()
                    }
                }
            } compactLeading: {
                // コンパクト表示（左）
                Text(context.attributes.metadata.emoji)
            } compactTrailing: {
                // コンパクト表示（右）— 残り時間
                if context.state.isCountingDown {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.red)
                }
            } minimal: {
                // 最小表示
                Text(context.attributes.metadata.emoji)
            }
        }
    }
}

// MARK: - ロック画面 Live Activity View

/// ロック画面・StandBy に表示される Live Activity の UI
struct CookingTimerLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<CookingAlarmMetadata>>

    var body: some View {
        VStack(spacing: 12) {
            // ヘッダー
            HStack {
                Text(context.attributes.metadata.emoji)
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.metadata.timerName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(context.attributes.metadata.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // ステータスバッジ
                if context.state.isCountingDown {
                    Label("調理中", systemImage: "flame.fill")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.2))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                } else {
                    Label("完了", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }

            // カウントダウン or 完了メッセージ
            if context.state.isCountingDown {
                HStack {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                    Text("残り時間")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.red)
                    Text("\(context.attributes.metadata.timerName)が完了しました!")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
            }
        }
        .padding()
    }
}
