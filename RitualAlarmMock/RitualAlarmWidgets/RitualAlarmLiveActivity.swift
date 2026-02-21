import ActivityKit
import AlarmKit
import WidgetKit
import SwiftUI

/// RitualAlarm の Live Activity 定義
struct RitualAlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "RitualAlarmRoutine",
            provider: RitualAlarmTimelineProvider()
        ) { entry in
            RitualAlarmWidgetView(entry: entry)
        }
        .configurationDisplayName("RitualAlarm ルーティン")
        .description("朝のルーティンの進捗を表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Provider

struct RitualAlarmTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> RitualAlarmWidgetEntry {
        RitualAlarmWidgetEntry(date: .now, currentStep: .stretch, completedSteps: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (RitualAlarmWidgetEntry) -> Void) {
        let entry = RitualAlarmWidgetEntry(date: .now, currentStep: .stretch, completedSteps: 1)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RitualAlarmWidgetEntry>) -> Void) {
        let entry = RitualAlarmWidgetEntry(date: .now, currentStep: .wakeUp, completedSteps: 0)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60 * 15)))
        completion(timeline)
    }
}

// MARK: - Widget Entry

struct RitualAlarmWidgetEntry: TimelineEntry {
    let date: Date
    let currentStep: RoutineStep
    let completedSteps: Int
}

// MARK: - Widget View

struct RitualAlarmWidgetView: View {
    let entry: RitualAlarmWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "sunrise.fill")
                    .foregroundStyle(.orange)
                Text("RitualAlarm")
                    .font(.caption.bold())
                Spacer()
            }

            Spacer()

            // ステップ進捗
            HStack(spacing: 4) {
                ForEach(RoutineStep.allCases) { step in
                    VStack(spacing: 2) {
                        Text(step.emoji)
                            .font(.caption2)
                        Circle()
                            .fill(step.index < entry.completedSteps ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }

            Text("\(entry.completedSteps) / \(RoutineStep.totalCount) ステップ")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
