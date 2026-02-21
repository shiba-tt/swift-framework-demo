import WidgetKit
import SwiftUI

// MARK: - DreamJournalWidget

struct DreamJournalWidget: Widget {
    let kind = "DreamJournalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DreamWidgetProvider()) { entry in
            DreamWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("DreamJournal")
        .description("最近の夢と感情の記録を表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Widget Entry

struct DreamWidgetEntry: TimelineEntry {
    let date: Date
    let latestDreamTitle: String?
    let latestDreamEmoji: String
    let totalDreams: Int
    let streakDays: Int
    let recentEmotions: [String]
}

// MARK: - Widget Provider

struct DreamWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DreamWidgetEntry {
        DreamWidgetEntry(
            date: .now,
            latestDreamTitle: "空を飛ぶ夢",
            latestDreamEmoji: "😌",
            totalDreams: 42,
            streakDays: 7,
            recentEmotions: ["😊", "😌", "😰", "🗺️", "😢"]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DreamWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DreamWidgetEntry>) -> Void) {
        let entry = DreamWidgetEntry(
            date: .now,
            latestDreamTitle: nil,
            latestDreamEmoji: "💭",
            totalDreams: 0,
            streakDays: 0,
            recentEmotions: []
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View

struct DreamWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: DreamWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryCircular:
            circularWidget
        case .accessoryRectangular:
            rectangularWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(.purple)
                Spacer()
                Text("\(entry.streakDays)日連続")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let title = entry.latestDreamTitle {
                Text(entry.latestDreamEmoji)
                    .font(.title)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            } else {
                Text("💭")
                    .font(.title)
                Text("夢を記録しましょう")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("全\(entry.totalDreams)件の記録")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(4)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 左側: 最新の夢
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(.purple)
                    Text("DreamJournal")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                Spacer()

                if let title = entry.latestDreamTitle {
                    Text(entry.latestDreamEmoji)
                        .font(.largeTitle)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                } else {
                    Text("💭")
                        .font(.largeTitle)
                    Text("今日の夢を記録")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 右側: 統計
            VStack(alignment: .trailing, spacing: 12) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(entry.totalDreams)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("総記録数")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(entry.streakDays)日")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    Text("連続記録")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // 感情アイコン列
                if !entry.recentEmotions.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(entry.recentEmotions.prefix(5), id: \.self) { emoji in
                            Text(emoji)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(4)
    }

    // MARK: - Circular Widget

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Text(entry.latestDreamEmoji)
                    .font(.title3)
                Text("\(entry.totalDreams)")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
    }

    // MARK: - Rectangular Widget

    private var rectangularWidget: some View {
        HStack(spacing: 8) {
            Text(entry.latestDreamEmoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.latestDreamTitle ?? "夢を記録")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text("記録数: \(entry.totalDreams) | 連続: \(entry.streakDays)日")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
