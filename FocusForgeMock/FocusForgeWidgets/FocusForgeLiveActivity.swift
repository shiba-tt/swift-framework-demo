import ActivityKit
import AlarmKit
import WidgetKit
import SwiftUI

/// FocusForge の Live Activity 定義
/// ロック画面・Dynamic Island・StandBy でカウントダウンを表示
struct FocusForgeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        // AlarmKit の AlarmAttributes を使用した ActivityConfiguration は
        // FocusForgeAlarmMetadata.activityConfiguration で定義済み
        // ここでは補助的なウィジェットを定義

        StaticConfiguration(
            kind: "FocusForgeTimer",
            provider: FocusForgeTimelineProvider()
        ) { entry in
            FocusForgeWidgetView(entry: entry)
        }
        .configurationDisplayName("FocusForge タイマー")
        .description("ポモドーロタイマーの状態を表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Provider

struct FocusForgeTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> FocusForgeWidgetEntry {
        FocusForgeWidgetEntry(date: .now, phase: .work, completedCount: 3, dailyGoal: 8)
    }

    func getSnapshot(in context: Context, completion: @escaping (FocusForgeWidgetEntry) -> Void) {
        let entry = FocusForgeWidgetEntry(date: .now, phase: .work, completedCount: 3, dailyGoal: 8)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusForgeWidgetEntry>) -> Void) {
        let entry = FocusForgeWidgetEntry(date: .now, phase: .work, completedCount: 0, dailyGoal: 8)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60 * 15)))
        completion(timeline)
    }
}

// MARK: - Widget Entry

struct FocusForgeWidgetEntry: TimelineEntry {
    let date: Date
    let phase: PomodoroPhase
    let completedCount: Int
    let dailyGoal: Int
}

// MARK: - Widget View

struct FocusForgeWidgetView: View {
    let entry: FocusForgeWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: entry.phase.systemImageName)
                    .foregroundStyle(entry.phase == .work ? .orange : .green)
                Text("FocusForge")
                    .font(.caption.bold())
                Spacer()
            }

            Spacer()

            // 進捗インジケーター
            HStack(spacing: 4) {
                ForEach(0..<entry.dailyGoal, id: \.self) { index in
                    Circle()
                        .fill(index < entry.completedCount ? Color.orange : Color.orange.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }

            Text("\(entry.completedCount) / \(entry.dailyGoal)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
