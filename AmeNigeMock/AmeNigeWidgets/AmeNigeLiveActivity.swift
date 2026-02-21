import ActivityKit
import WidgetKit
import SwiftUI

/// Live Activity 用の属性定義
struct AmeNigeActivityAttributes: ActivityAttributes {
    /// 動的に更新されるコンテンツ
    struct ContentState: Codable, Hashable {
        /// 現在降水中かどうか
        let isRaining: Bool
        /// 降水強度 (mm/h)
        let intensityMmPerHour: Double
        /// 降水レベルの表示名
        let levelName: String
        /// 降水レベルのアイコン名
        let levelIcon: String
        /// 雨までの残り分数（降水なしの場合）
        let minutesUntilRain: Int?
        /// 雨が止むまでの残り分数（降水中の場合）
        let minutesUntilStop: Int?
        /// 外出判定のタイトル
        let verdictTitle: String
    }

    /// 固定情報
    let locationName: String
}

// MARK: - Live Activity Widget

struct AmeNigeLiveActivity: Widget {
    let kind: String = "AmeNigeLiveActivity"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AmeNigeActivityAttributes.self) { context in
            // ロック画面表示
            lockScreenView(context: context)
                .activityBackgroundTint(.cyan.opacity(0.2))
        } dynamicIsland: { context in
            DynamicIsland {
                // 展開時
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.isRaining ? "umbrella.fill" : "sun.max.fill")
                        .font(.title2)
                        .foregroundStyle(context.state.isRaining ? .cyan : .yellow)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text(String(format: "%.1f", context.state.intensityMmPerHour))
                            .font(.title3.monospacedDigit().bold())
                        Text("mm/h")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.verdictTitle)
                        .font(.subheadline.bold())
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if let minutes = context.state.minutesUntilRain {
                            Label("雨まで\(minutes)分", systemImage: "timer")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        } else if let minutes = context.state.minutesUntilStop {
                            Label("止むまで\(minutes)分", systemImage: "clock.fill")
                                .font(.caption)
                                .foregroundStyle(.cyan)
                        }
                        Spacer()
                        Text(context.attributes.locationName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                // コンパクト（左側）
                Image(systemName: context.state.isRaining ? "umbrella.fill" : "sun.max.fill")
                    .foregroundStyle(context.state.isRaining ? .cyan : .yellow)
            } compactTrailing: {
                // コンパクト（右側）
                if let minutes = context.state.minutesUntilRain {
                    Text("\(minutes)分")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.orange)
                } else {
                    Text(context.state.levelName)
                        .font(.caption2)
                }
            } minimal: {
                // ミニマル
                Image(systemName: context.state.isRaining ? "umbrella.fill" : "sun.max.fill")
                    .foregroundStyle(context.state.isRaining ? .cyan : .yellow)
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    private func lockScreenView(
        context: ActivityViewContext<AmeNigeActivityAttributes>
    ) -> some View {
        HStack(spacing: 16) {
            // 左: 天候アイコン
            VStack(spacing: 4) {
                Image(systemName: context.state.levelIcon)
                    .font(.largeTitle)
                    .foregroundStyle(context.state.isRaining ? .cyan : .yellow)

                Text(context.state.levelName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)

            // 中央: 判定情報
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.verdictTitle)
                    .font(.headline.bold())

                if let minutes = context.state.minutesUntilRain {
                    Label("雨まであと\(minutes)分", systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else if let minutes = context.state.minutesUntilStop {
                    Label("止むまであと\(minutes)分", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                }
            }

            Spacer()

            // 右: 降水強度
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", context.state.intensityMmPerHour))
                    .font(.title2.monospacedDigit().bold())
                Text("mm/h")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}
