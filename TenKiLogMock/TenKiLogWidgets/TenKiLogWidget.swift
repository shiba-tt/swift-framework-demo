import WidgetKit
import SwiftUI

/// TenKi Log 天気ログウィジェット
struct TenKiLogWidget: Widget {
    let kind = "TenKiLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TenKiLogWidgetProvider()) { entry in
            TenKiLogWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TenKi Log")
        .description("今日の天気と気分を記録します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TenKiLogWidgetEntry: TimelineEntry {
    let date: Date
    let weatherEmoji: String
    let weatherName: String
    let temperatureRange: String
    let moodEmoji: String?
    let pressure: String
    let diaryNote: String?
}

struct TenKiLogWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TenKiLogWidgetEntry {
        TenKiLogWidgetEntry(
            date: Date(),
            weatherEmoji: "\u{2600}\u{FE0F}",
            weatherName: "晴れ",
            temperatureRange: "8\u{00B0}C / 18\u{00B0}C",
            moodEmoji: "\u{1F60A}",
            pressure: "1013 hPa",
            diaryNote: "いい天気の一日"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TenKiLogWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TenKiLogWidgetEntry>) -> Void) {
        let entry = TenKiLogWidgetEntry(
            date: Date(),
            weatherEmoji: "\u{26C5}",
            weatherName: "晴れ時々曇り",
            temperatureRange: "10\u{00B0}C / 16\u{00B0}C",
            moodEmoji: "\u{1F642}",
            pressure: "1018 hPa",
            diaryNote: "散歩した"
        )
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct TenKiLogWidgetEntryView: View {
    let entry: TenKiLogWidgetEntry

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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .foregroundStyle(.cyan)
                Text("TenKi Log")
                    .font(.caption2)
                    .fontWeight(.bold)
            }

            Spacer()

            Text(entry.weatherEmoji)
                .font(.system(size: 32))

            Text(entry.temperatureRange)
                .font(.caption)
                .fontWeight(.medium)

            HStack(spacing: 4) {
                if let mood = entry.moodEmoji {
                    Text(mood)
                        .font(.caption)
                }
                Text(entry.weatherName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundStyle(.cyan)
                    Text("TenKi Log")
                        .font(.caption)
                        .fontWeight(.bold)
                }

                Text(entry.weatherEmoji)
                    .font(.system(size: 36))

                Text(entry.temperatureRange)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(entry.weatherName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "gauge.with.dots.needle.33percent")
                        .font(.system(size: 10))
                        .foregroundStyle(.purple)
                    Text(entry.pressure)
                        .font(.caption2)
                }

                if let mood = entry.moodEmoji {
                    HStack(spacing: 4) {
                        Text(mood)
                            .font(.caption)
                        Text("今日の気分")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                if let note = entry.diaryNote {
                    Text(note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@main
struct TenKiLogWidgetBundle: WidgetBundle {
    var body: some Widget {
        TenKiLogWidget()
    }
}
