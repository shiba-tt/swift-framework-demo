import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct ScheduleWidgetEntry: TimelineEntry {
    let date: Date
    let nextEvent: ScheduleEvent?
    let freeSlot: TimeSlot?
    let totalEventsToday: Int
    let totalFreeMinutes: Int
}

// MARK: - Timeline Provider

struct ScheduleWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleWidgetEntry {
        ScheduleWidgetEntry(
            date: .now,
            nextEvent: nil,
            freeSlot: nil,
            totalEventsToday: 5,
            totalFreeMinutes: 120
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleWidgetEntry) -> Void) {
        let entry = ScheduleWidgetEntry(
            date: .now,
            nextEvent: nil,
            freeSlot: nil,
            totalEventsToday: 3,
            totalFreeMinutes: 90
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleWidgetEntry>) -> Void) {
        let entry = ScheduleWidgetEntry(
            date: .now,
            nextEvent: nil,
            freeSlot: nil,
            totalEventsToday: 0,
            totalFreeMinutes: 0
        )
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(1800))
        )
        completion(timeline)
    }
}

// MARK: - Widget View

struct ScheduleWidgetView: View {
    var entry: ScheduleWidgetEntry

    @Environment(\.widgetFamily) var family

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

    // MARK: - Small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "map.fill")
                    .foregroundStyle(.indigo)
                Text("TimeMap")
                    .font(.caption.bold())
            }

            Spacer()

            if let event = entry.nextEvent {
                VStack(alignment: .leading, spacing: 2) {
                    Text("次の予定")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(event.title)
                        .font(.caption.bold())
                        .lineLimit(2)
                }
            } else {
                Text("予定なし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("\(entry.totalEventsToday)", systemImage: "calendar")
                Spacer()
                Label("\(entry.totalFreeMinutes)m", systemImage: "clock")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium

    private var mediumView: some View {
        HStack(spacing: 12) {
            // 左側：統計
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.indigo)
                    Text("TimeMap")
                        .font(.caption.bold())
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Label("\(entry.totalEventsToday)件の予定", systemImage: "calendar")
                    Label("空き\(entry.totalFreeMinutes)分", systemImage: "clock")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // 右側：次の予定
            VStack(alignment: .leading, spacing: 4) {
                Text("次の予定")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let event = entry.nextEvent {
                    Text(event.title)
                        .font(.subheadline.bold())
                        .lineLimit(2)
                    if let location = event.location {
                        Label(location, systemImage: "mappin")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                } else {
                    Text("予定なし")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Circular

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "map.fill")
                    .font(.caption)
                Text("\(entry.totalEventsToday)")
                    .font(.title3.bold())
                Text("件")
                    .font(.system(size: 8))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Rectangular

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "map.fill")
                Text("TimeMap")
                    .font(.caption.bold())
            }
            Text("予定 \(entry.totalEventsToday)件 | 空き \(entry.totalFreeMinutes)分")
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let event = entry.nextEvent {
                Text("次: \(event.title)")
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct TimeMapScheduleWidget: Widget {
    let kind: String = "TimeMapScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleWidgetProvider()) { entry in
            ScheduleWidgetView(entry: entry)
        }
        .configurationDisplayName("TimeMap スケジュール")
        .description("今日の予定と空き時間を地図視点で表示")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}
