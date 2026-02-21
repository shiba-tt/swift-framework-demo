import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct GridPulseEntry: TimelineEntry {
    let date: Date
    let cleanFraction: Double
    let level: GridLevel
    let themeName: String
    let hourlyData: [HourlyClean]
}

struct HourlyClean: Sendable {
    let hour: Int
    let cleanFraction: Double
}

// MARK: - Timeline Provider

struct GridPulseProvider: TimelineProvider {
    func placeholder(in context: Context) -> GridPulseEntry {
        GridPulseEntry(
            date: .now,
            cleanFraction: 0.78,
            level: .veryClean,
            themeName: "風と太陽の午後",
            hourlyData: (0..<24).map { HourlyClean(hour: $0, cleanFraction: 0.5) }
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GridPulseEntry) -> Void) {
        let entry = GridPulseEntry(
            date: .now,
            cleanFraction: 0.72,
            level: .veryClean,
            themeName: "穏やかな風の午後",
            hourlyData: (0..<24).map { HourlyClean(hour: $0, cleanFraction: Double.random(in: 0.3...0.9)) }
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GridPulseEntry>) -> Void) {
        let entry = GridPulseEntry(
            date: .now,
            cleanFraction: 0.65,
            level: .clean,
            themeName: "穏やかな風の一日",
            hourlyData: (0..<24).map { HourlyClean(hour: $0, cleanFraction: Double.random(in: 0.3...0.9)) }
        )
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(1800))
        )
        completion(timeline)
    }
}

// MARK: - Widget View

struct GridPulseWidgetView: View {
    var entry: GridPulseEntry

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
                Image(systemName: "bolt.heart.fill")
                    .foregroundStyle(.green)
                Text("GridPulse")
                    .font(.caption.bold())
            }

            Spacer()

            Text("\(Int(entry.cleanFraction * 100))%")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(entry.level.color)

            Text(entry.level.label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            // ミニバー
            HStack(spacing: 1) {
                ForEach(0..<24, id: \.self) { hour in
                    let clean = entry.hourlyData.first { $0.hour == hour }?.cleanFraction ?? 0
                    RoundedRectangle(cornerRadius: 1)
                        .fill(colorForClean(clean))
                        .frame(height: 6)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium

    private var mediumView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "bolt.heart.fill")
                        .foregroundStyle(.green)
                    Text("GridPulse")
                        .font(.caption.bold())
                }

                Spacer()

                Text("\(Int(entry.cleanFraction * 100))%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.level.color)

                Text(entry.themeName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // タイムラインバー
            VStack(alignment: .leading, spacing: 4) {
                Text("24h タイムライン")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                HStack(alignment: .bottom, spacing: 1) {
                    ForEach(0..<24, id: \.self) { hour in
                        let clean = entry.hourlyData.first { $0.hour == hour }?.cleanFraction ?? 0
                        RoundedRectangle(cornerRadius: 1)
                            .fill(colorForClean(clean))
                            .frame(height: max(4, 50 * clean))
                    }
                }

                HStack {
                    Text("0")
                    Spacer()
                    Text("12")
                    Spacer()
                    Text("23")
                }
                .font(.system(size: 7))
                .foregroundStyle(.secondary)
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
                Image(systemName: "bolt.heart.fill")
                    .font(.caption)
                Text("\(Int(entry.cleanFraction * 100))")
                    .font(.title3.bold())
                Text("%")
                    .font(.system(size: 8))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Rectangular

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "bolt.heart.fill")
                Text("GridPulse")
                    .font(.caption.bold())
            }
            Text("\(entry.level.emoji) \(Int(entry.cleanFraction * 100))% クリーン")
                .font(.caption2)
            Text(entry.themeName)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Helpers

    private func colorForClean(_ fraction: Double) -> Color {
        switch fraction {
        case 0.7...: .green
        case 0.5..<0.7: .mint
        case 0.3..<0.5: .yellow
        default: .red
        }
    }
}

// MARK: - Widget Definition

struct GridPulseArtWidget: Widget {
    let kind: String = "GridPulseArtWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GridPulseProvider()) { entry in
            GridPulseWidgetView(entry: entry)
        }
        .configurationDisplayName("GridPulse アート")
        .description("電力グリッドのクリーン度をアートとして表示")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}
