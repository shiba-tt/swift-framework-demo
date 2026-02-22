import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Attributes

/// キーボードメトリクス記録中のライブアクティビティ
struct KeyboardRecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var riskLevel: String
        var averageWPM: Double
        var errorRate: Double
        var recordingMinutes: Int
    }

    var sessionStartDate: Date
}

// MARK: - Live Activity Widget

struct TypeGuardLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KeyboardRecordingAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "keyboard.badge.eye.fill")
                            .font(.title3)
                        Text("TypeGuard")
                            .font(.caption2)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.0f WPM", context.state.averageWPM))
                            .font(.caption)
                            .monospacedDigit()
                            .fontWeight(.bold)
                        Text(context.state.riskLevel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("キーボード記録中")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label(
                            String(format: "Err: %.1f%%", context.state.errorRate * 100),
                            systemImage: "xmark.circle"
                        )
                        .font(.caption2)
                        Spacer()
                        Label(
                            "\(context.state.recordingMinutes)分間記録",
                            systemImage: "clock"
                        )
                        .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "keyboard.badge.eye.fill")
                    .font(.caption2)
            } compactTrailing: {
                Text(String(format: "%.0f", context.state.averageWPM))
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "keyboard.fill")
                    .font(.caption2)
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<KeyboardRecordingAttributes>) -> some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Image(systemName: "keyboard.badge.eye.fill")
                    .font(.title2)
                    .foregroundStyle(.teal)
                Text("記録中")
                    .font(.caption2)
                    .fontWeight(.medium)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("TypeGuard")
                    .font(.headline)
                Text(context.state.riskLevel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(
                        String(format: "%.0f WPM", context.state.averageWPM),
                        systemImage: "gauge.with.dots.needle.50percent"
                    )
                    .font(.caption)
                    Label(
                        String(format: "%.1f%%", context.state.errorRate * 100),
                        systemImage: "xmark.circle"
                    )
                    .font(.caption)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text("\(context.state.recordingMinutes)分")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
