import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct ChronoSenseEntry: TimelineEntry {
    let date: Date
    let rhythmScore: Int
    let scoreLevel: String
    let peakActivityHour: Int
    let totalSteps: Int
    let sleepHours: Int
}

// MARK: - Timeline Provider

struct ChronoSenseProvider: TimelineProvider {
    func placeholder(in context: Context) -> ChronoSenseEntry {
        ChronoSenseEntry(
            date: Date(),
            rhythmScore: 78,
            scoreLevel: "良好",
            peakActivityHour: 14,
            totalSteps: 8500,
            sleepHours: 7
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ChronoSenseEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ChronoSenseEntry>) -> Void) {
        let entry = ChronoSenseEntry(
            date: Date(),
            rhythmScore: Int.random(in: 60...95),
            scoreLevel: "良好",
            peakActivityHour: Int.random(in: 10...16),
            totalSteps: Int.random(in: 3000...12000),
            sleepHours: Int.random(in: 5...9)
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Views

struct ChronoSenseWidgetEntryView: View {
    var entry: ChronoSenseEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

private struct SmallWidgetView: View {
    let entry: ChronoSenseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.indigo)
                Text("ChronoSense")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(entry.rhythmScore)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text("リズム整合度")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

private struct MediumWidgetView: View {
    let entry: ChronoSenseEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.indigo)
                    Text("ChronoSense")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(entry.rhythmScore)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                Text("リズム整合度: \(entry.scoreLevel)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                MediumStatRow(icon: "figure.walk", label: "歩数", value: "\(entry.totalSteps)")
                MediumStatRow(icon: "sun.max.fill", label: "活動ピーク", value: "\(entry.peakActivityHour):00")
                MediumStatRow(icon: "bed.double.fill", label: "睡眠", value: "\(entry.sleepHours)h")
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

private struct MediumStatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

private struct CircularWidgetView: View {
    let entry: ChronoSenseEntry

    var body: some View {
        Gauge(value: Double(entry.rhythmScore), in: 0...100) {
            Image(systemName: "clock.fill")
        } currentValueLabel: {
            Text("\(entry.rhythmScore)")
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct ChronoSenseWidget: Widget {
    let kind = "ChronoSenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChronoSenseProvider()) { entry in
            ChronoSenseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ChronoSense")
        .description("概日リズムの整合度スコアを表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}
