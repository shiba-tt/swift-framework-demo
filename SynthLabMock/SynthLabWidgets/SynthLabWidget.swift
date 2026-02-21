import WidgetKit
import SwiftUI

/// SynthLab レッスン進捗ウィジェット
struct SynthLabWidget: Widget {
    let kind = "SynthLabWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SynthLabWidgetProvider()) { entry in
            SynthLabWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("SynthLab 進捗")
        .description("シンセサイザー学習の進捗状況を表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SynthLabWidgetEntry: TimelineEntry {
    let date: Date
    let completedLessons: Int
    let totalLessons: Int
    let currentLessonTitle: String?
    let lastPlayedPreset: String?
}

struct SynthLabWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SynthLabWidgetEntry {
        SynthLabWidgetEntry(
            date: Date(),
            completedLessons: 3,
            totalLessons: 5,
            currentLessonTitle: "フィルターを理解しよう",
            lastPlayedPreset: "Warm Bass"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SynthLabWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SynthLabWidgetEntry>) -> Void) {
        let entry = SynthLabWidgetEntry(
            date: Date(),
            completedLessons: 2,
            totalLessons: 5,
            currentLessonTitle: "音を削る：フィルター",
            lastPlayedPreset: "Screaming Lead"
        )
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct SynthLabWidgetEntryView: View {
    let entry: SynthLabWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(.indigo)
                Text("SynthLab")
                    .font(.caption2)
                    .fontWeight(.bold)
            }

            Spacer()

            Text("\(entry.completedLessons)/\(entry.totalLessons)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.indigo)

            Text("レッスン完了")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 左：進捗
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundStyle(.indigo)
                    Text("SynthLab")
                        .font(.caption)
                        .fontWeight(.bold)
                }

                Text("\(entry.completedLessons)/\(entry.totalLessons)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.indigo)

                Text("レッスン完了")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // 右：現在の学習
            VStack(alignment: .leading, spacing: 8) {
                if let title = entry.currentLessonTitle {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("学習中")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }

                if let preset = entry.lastPlayedPreset {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最後のプリセット")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(preset)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@main
struct SynthLabWidgetBundle: WidgetBundle {
    var body: some Widget {
        SynthLabWidget()
    }
}
