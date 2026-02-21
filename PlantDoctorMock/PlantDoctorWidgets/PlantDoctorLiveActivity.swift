import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Attributes

/// 水やりタイマーのライブアクティビティ属性
struct WateringTimerAttributes: ActivityAttributes {
    /// 動的に更新されるコンテンツ
    public struct ContentState: Codable, Hashable {
        var plantName: String
        var plantEmoji: String
        var remainingMinutes: Int
        var soilMoisturePercent: Int
        var statusMessage: String
    }

    /// 固定の属性
    var startedAt: Date
}

// MARK: - Live Activity Widget

/// 水やりタイマー Live Activity
struct PlantDoctorLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WateringTimerAttributes.self) { context in
            // ロック画面表示
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // 展開時の表示
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.plantEmoji)
                            .font(.title2)
                        Text(context.state.plantName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("💧 \(context.state.soilMoisturePercent)%")
                            .font(.caption)
                            .monospacedDigit()
                        Text("あと\(context.state.remainingMinutes)分")
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("水やり中")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    // 水分ゲージ
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(.systemGray4))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.blue)
                                    .frame(
                                        width: geometry.size.width * CGFloat(context.state.soilMoisturePercent) / 100,
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)
                        Text("\(context.state.soilMoisturePercent)%")
                            .font(.caption2)
                            .monospacedDigit()
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Text(context.state.plantEmoji)
                        .font(.caption)
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            } compactTrailing: {
                Text("\(context.state.remainingMinutes)分")
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
    }

    // MARK: - Lock Screen View

    private func lockScreenView(context: ActivityViewContext<WateringTimerAttributes>) -> some View {
        HStack(spacing: 16) {
            // 植物情報
            VStack(spacing: 4) {
                Text(context.state.plantEmoji)
                    .font(.title)
                Text(context.state.plantName)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            // 水分ゲージと残り時間
            VStack(alignment: .leading, spacing: 6) {
                Text("水やり中")
                    .font(.headline)

                HStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(.blue)
                    Text("土壌水分: \(context.state.soilMoisturePercent)%")
                        .font(.subheadline)
                        .monospacedDigit()
                }

                Text(context.state.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 残り時間
            VStack(spacing: 2) {
                Text("\(context.state.remainingMinutes)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                Text("分")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
