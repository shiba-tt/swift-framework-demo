import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Attributes

/// スプリントカウントダウンのライブアクティビティ
struct SprintCountdownAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var completedTasks: Int
        var totalTasks: Int
        var onlineMembers: Int
        var totalMembers: Int
        var sprintEndDate: Date
        var lastUpdated: String
    }

    var sprintName: String
    var boardName: String
}

// MARK: - Live Activity Widget

struct LiveBoardLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SprintCountdownAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("📋 \(context.attributes.boardName)")
                            .font(.caption2)
                            .fontWeight(.bold)
                        Text(context.attributes.sprintName)
                            .font(.caption)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        let percentage = context.state.totalTasks > 0
                            ? Int(Double(context.state.completedTasks) / Double(context.state.totalTasks) * 100)
                            : 0
                        Text("\(percentage)%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        Text("完了率")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("残り")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        // 進捗バー
                        VStack(alignment: .leading, spacing: 4) {
                            ProgressView(
                                value: Double(context.state.completedTasks),
                                total: Double(max(context.state.totalTasks, 1))
                            )
                            .tint(.blue)

                            HStack {
                                Text("\(context.state.completedTasks)/\(context.state.totalTasks) タスク完了")
                                    .font(.caption2)
                                Spacer()
                                HStack(spacing: 2) {
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 5, height: 5)
                                    Text("\(context.state.onlineMembers)人オンライン")
                                        .font(.caption2)
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            } compactLeading: {
                Text("📋")
                    .font(.system(size: 14))
            } compactTrailing: {
                let percentage = context.state.totalTasks > 0
                    ? Int(Double(context.state.completedTasks) / Double(context.state.totalTasks) * 100)
                    : 0
                Text("\(percentage)%")
                    .font(.caption2)
                    .monospacedDigit()
                    .fontWeight(.bold)
            } minimal: {
                Text("📋")
                    .font(.system(size: 12))
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<SprintCountdownAttributes>) -> some View {
        VStack(spacing: 12) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("📋 \(context.attributes.boardName)")
                        .font(.headline)
                    Text(context.attributes.sprintName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // スプリント残り時間
                VStack(alignment: .trailing, spacing: 2) {
                    Text(context.state.sprintEndDate, style: .timer)
                        .font(.title3)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    Text("残り時間")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // 進捗
            VStack(spacing: 6) {
                ProgressView(
                    value: Double(context.state.completedTasks),
                    total: Double(max(context.state.totalTasks, 1))
                )
                .tint(.blue)

                HStack {
                    Label(
                        "\(context.state.completedTasks)/\(context.state.totalTasks) タスク完了",
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.caption)

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                        Text("\(context.state.onlineMembers)/\(context.state.totalMembers)人オンライン")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
