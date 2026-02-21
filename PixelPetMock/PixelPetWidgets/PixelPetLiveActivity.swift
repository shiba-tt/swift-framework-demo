import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Attributes

/// ペットのお世話中ライブアクティビティの属性
struct PetCareAttributes: ActivityAttributes {
    /// 動的に更新されるコンテンツ
    public struct ContentState: Codable, Hashable {
        var petName: String
        var faceText: String
        var hunger: Int
        var happiness: Int
        var mood: String
        var lastAction: String
    }

    /// 固定の属性
    var species: String
}

// MARK: - Live Activity Widget

/// ペットのお世話 Live Activity
struct PixelPetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetCareAttributes.self) { context in
            // ロック画面表示
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // 展開時の表示
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.species)
                            .font(.title2)
                        Text(context.state.faceText)
                            .font(.system(size: 16, design: .monospaced))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("❤️ \(context.state.hunger)")
                            .font(.caption)
                            .monospacedDigit()
                        Text("⭐ \(context.state.happiness)")
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.petName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption2)
                        Text(context.state.lastAction)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text(context.state.faceText)
                    .font(.system(size: 12, design: .monospaced))
            } compactTrailing: {
                Text("❤️\(context.state.hunger)")
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Text(context.state.faceText)
                    .font(.system(size: 10, design: .monospaced))
            }
        }
    }

    // MARK: - Lock Screen View

    private func lockScreenView(context: ActivityViewContext<PetCareAttributes>) -> some View {
        HStack(spacing: 16) {
            // ペット
            VStack(spacing: 4) {
                Text(context.attributes.species)
                    .font(.title)
                Text(context.state.faceText)
                    .font(.system(size: 20, design: .monospaced))
                    .fontWeight(.bold)
            }

            // ステータス
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.petName)
                    .font(.headline)
                Text(context.state.mood)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label("\(context.state.hunger)", systemImage: "heart.fill")
                        .font(.caption)
                    Label("\(context.state.happiness)", systemImage: "star.fill")
                        .font(.caption)
                }
            }

            Spacer()

            // 最後のアクション
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                Text(context.state.lastAction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
