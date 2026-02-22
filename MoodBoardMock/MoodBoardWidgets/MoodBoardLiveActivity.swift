import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Attributes

/// 気分記録のライブアクティビティ
struct MoodRecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var todayEmoji: String
        var todayMood: String
        var streakDays: Int
        var recordedTime: String
    }

    var appName: String
}

// MARK: - Live Activity Widget

struct MoodBoardLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoodRecordingAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.todayEmoji)
                            .font(.title2)
                        Text(context.state.todayMood)
                            .font(.caption2)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("連続\(context.state.streakDays)日")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text(context.state.recordedTime)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("MoodBoard")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("今日の気分を記録しました")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text(context.state.todayEmoji)
                    .font(.system(size: 14))
            } compactTrailing: {
                Text("\(context.state.streakDays)日")
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Text(context.state.todayEmoji)
                    .font(.system(size: 12))
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<MoodRecordingAttributes>) -> some View {
        HStack(spacing: 16) {
            Text(context.state.todayEmoji)
                .font(.system(size: 36))

            VStack(alignment: .leading, spacing: 4) {
                Text("MoodBoard")
                    .font(.headline)
                Text(context.state.todayMood)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label("連続\(context.state.streakDays)日", systemImage: "flame.fill")
                        .font(.caption)
                    Label(context.state.recordedTime, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
    }
}
