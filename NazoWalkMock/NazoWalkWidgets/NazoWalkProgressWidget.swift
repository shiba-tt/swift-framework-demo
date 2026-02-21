import SwiftUI
import WidgetKit

/// 謎解き進捗ウィジェット
struct NazoWalkProgressWidget: Widget {
    let kind = "NazoWalkProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NazoWalkTimelineProvider()) { entry in
            NazoWalkWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("謎解き進捗")
        .description("まちなか謎解きアドベンチャーの進捗を表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Timeline Entry

struct NazoWalkEntry: TimelineEntry {
    let date: Date
    let clearedCount: Int
    let totalCount: Int
    let totalPoints: Int
    let isCompleted: Bool
    let nextSpotName: String?
}

// MARK: - Timeline Provider

struct NazoWalkTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NazoWalkEntry {
        NazoWalkEntry(
            date: .now,
            clearedCount: 2,
            totalCount: 4,
            totalPoints: 250,
            isCompleted: false,
            nextSpotName: "蓮池公園のベンチ"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NazoWalkEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NazoWalkEntry>) -> Void) {
        let entry = placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget View

struct NazoWalkWidgetView: View {
    let entry: NazoWalkEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 8) {
            Image(systemName: entry.isCompleted ? "trophy.fill" : "questionmark.circle.fill")
                .font(.title)
                .foregroundStyle(.orange)

            Text("\(entry.clearedCount)/\(entry.totalCount)")
                .font(.title2)
                .fontWeight(.bold)

            Text("\(entry.totalPoints) pt")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: Double(entry.clearedCount), total: Double(entry.totalCount))
                .tint(.orange)
        }
    }

    private var mediumView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Label("NazoWalk", systemImage: "map.fill")
                    .font(.headline)

                Text("\(entry.clearedCount)/\(entry.totalCount) クリア")
                    .font(.title3)
                    .fontWeight(.bold)

                ProgressView(value: Double(entry.clearedCount), total: Double(entry.totalCount))
                    .tint(.orange)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.totalPoints)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text("ポイント")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let next = entry.nextSpotName {
                    Divider()
                    Text("次: \(next)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    private var circularView: some View {
        Gauge(value: Double(entry.clearedCount), in: 0...Double(entry.totalCount)) {
            Image(systemName: "questionmark.circle.fill")
        } currentValueLabel: {
            Text("\(entry.clearedCount)")
        }
        .gaugeStyle(.accessoryCircular)
    }

    private var rectangularView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("NazoWalk")
                    .font(.caption2)
                    .fontWeight(.bold)
                Text("\(entry.clearedCount)/\(entry.totalCount) クリア")
                    .font(.caption)
            }
            Spacer()
            Text("\(entry.totalPoints)pt")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
