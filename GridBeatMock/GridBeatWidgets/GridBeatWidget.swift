import SwiftUI
import WidgetKit

// MARK: - Timeline Provider

struct GridBeatTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> GridBeatEntry {
        GridBeatEntry(
            date: Date(),
            cleanPercentage: 78,
            todayCO2Kg: 1.2,
            greenDaysThisMonth: 18
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GridBeatEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GridBeatEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> GridBeatEntry {
        guard let defaults = UserDefaults(suiteName: "group.com.example.gridbeat"),
              let data = defaults.data(forKey: "widgetData"),
              let widgetData = try? JSONDecoder().decode(GridBeatWidgetData.self, from: data) else {
            return GridBeatEntry(
                date: Date(),
                cleanPercentage: 72,
                todayCO2Kg: 1.5,
                greenDaysThisMonth: 15
            )
        }
        return GridBeatEntry(
            date: widgetData.lastUpdated,
            cleanPercentage: widgetData.currentCleanPercentage,
            todayCO2Kg: widgetData.todayCO2Kg,
            greenDaysThisMonth: widgetData.greenDaysThisMonth
        )
    }
}

// MARK: - Timeline Entry

struct GridBeatEntry: TimelineEntry {
    let date: Date
    let cleanPercentage: Int
    let todayCO2Kg: Double
    let greenDaysThisMonth: Int
}

// MARK: - Small Widget

struct GridBeatSmallWidgetView: View {
    let entry: GridBeatEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("GridBeat")
                    .font(.caption)
                    .fontWeight(.bold)
            }

            Spacer()

            Text(String(format: "%.1f", entry.todayCO2Kg))
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("kg CO\u{2082} \u{4ECA}\u{65E5}")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Circle()
                    .fill(cleanColor)
                    .frame(width: 6, height: 6)
                Text("\u{30AF}\u{30EA}\u{30FC}\u{30F3} \(entry.cleanPercentage)%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private var cleanColor: Color {
        if entry.cleanPercentage >= 70 {
            return .green
        } else if entry.cleanPercentage >= 40 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Medium Widget

struct GridBeatMediumWidgetView: View {
    let entry: GridBeatEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left: CO2
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                    Text("GridBeat")
                        .font(.caption)
                        .fontWeight(.bold)
                }

                Spacer()

                Text(String(format: "%.1f", entry.todayCO2Kg))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("kg CO\u{2082} \u{4ECA}\u{65E5}")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Right: Stats
            VStack(alignment: .leading, spacing: 8) {
                StatRow(
                    icon: "bolt.fill",
                    label: "\u{30AF}\u{30EA}\u{30FC}\u{30F3}\u{5EA6}",
                    value: "\(entry.cleanPercentage)%",
                    color: .green
                )
                StatRow(
                    icon: "calendar",
                    label: "\u{30B0}\u{30EA}\u{30FC}\u{30F3}\u{65E5}",
                    value: "\(entry.greenDaysThisMonth)\u{65E5}",
                    color: .blue
                )
            }
        }
        .padding()
    }
}

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 16)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Widget Definition

struct GridBeatWidget: Widget {
    let kind: String = "GridBeatWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GridBeatTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                GridBeatSmallWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                GridBeatSmallWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("GridBeat")
        .description("\u{4ECA}\u{65E5}\u{306E}\u{30AB}\u{30FC}\u{30DC}\u{30F3}\u{30D5}\u{30C3}\u{30C8}\u{30D7}\u{30EA}\u{30F3}\u{30C8}\u{3068}\u{30B0}\u{30EA}\u{30C3}\u{30C9}\u{72B6}\u{614B}")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Lock Screen Widget

struct GridBeatAccessoryWidget: Widget {
    let kind: String = "GridBeatAccessoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GridBeatTimelineProvider()) { entry in
            GridBeatAccessoryView(entry: entry)
        }
        .configurationDisplayName("GridBeat")
        .description("\u{30AB}\u{30FC}\u{30DC}\u{30F3}\u{30D5}\u{30C3}\u{30C8}\u{30D7}\u{30EA}\u{30F3}\u{30C8}")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct GridBeatAccessoryView: View {
    let entry: GridBeatEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 1) {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                Text(String(format: "%.1f", entry.todayCO2Kg))
                    .font(.headline)
                    .fontWeight(.bold)
            }
        case .accessoryRectangular:
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CO\u{2082} \u{4ECA}\u{65E5}")
                        .font(.caption2)
                    Text(String(format: "%.1f kg", entry.todayCO2Kg))
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\u{30AF}\u{30EA}\u{30FC}\u{30F3}")
                        .font(.caption2)
                    Text("\(entry.cleanPercentage)%")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
        default:
            Text(String(format: "%.1f", entry.todayCO2Kg))
        }
    }
}

#Preview(as: .systemSmall) {
    GridBeatWidget()
} timeline: {
    GridBeatEntry(date: Date(), cleanPercentage: 78, todayCO2Kg: 1.2, greenDaysThisMonth: 18)
}
