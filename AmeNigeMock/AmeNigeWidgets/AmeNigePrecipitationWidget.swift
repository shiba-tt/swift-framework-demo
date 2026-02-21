import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct PrecipitationWidgetEntry: TimelineEntry {
    let date: Date
    let isRaining: Bool
    let currentIntensity: Double
    let level: PrecipitationLevel
    let minutesUntilRain: Int?
    let nextDryWindowStart: String?
    let verdictTitle: String
}

// MARK: - Timeline Provider

struct PrecipitationWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrecipitationWidgetEntry {
        PrecipitationWidgetEntry(
            date: .now,
            isRaining: false,
            currentIntensity: 0,
            level: .none,
            minutesUntilRain: nil,
            nextDryWindowStart: nil,
            verdictTitle: "読み込み中..."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrecipitationWidgetEntry) -> Void) {
        let entry = PrecipitationWidgetEntry(
            date: .now,
            isRaining: false,
            currentIntensity: 0,
            level: .none,
            minutesUntilRain: 25,
            nextDryWindowStart: nil,
            verdictTitle: "今すぐ外出OK"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrecipitationWidgetEntry>) -> Void) {
        let entry = PrecipitationWidgetEntry(
            date: .now,
            isRaining: false,
            currentIntensity: 0,
            level: .none,
            minutesUntilRain: nil,
            nextDryWindowStart: nil,
            verdictTitle: "データなし"
        )
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(900)) // 15分後に更新
        )
        completion(timeline)
    }
}

// MARK: - Widget View

struct PrecipitationWidgetView: View {
    var entry: PrecipitationWidgetEntry

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
        case .accessoryInline:
            inlineView
        default:
            smallView
        }
    }

    // MARK: - Small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "umbrella.fill")
                    .foregroundStyle(.cyan)
                Text("AmeNige")
                    .font(.caption.bold())
            }

            Spacer()

            Image(systemName: entry.level.systemImageName)
                .font(.title)
                .foregroundStyle(levelColor)

            Text(entry.verdictTitle)
                .font(.caption.bold())

            if let minutes = entry.minutesUntilRain {
                Text("雨まで\(minutes)分")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium

    private var mediumView: some View {
        HStack(spacing: 16) {
            // 左: 現在状況
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "umbrella.fill")
                        .foregroundStyle(.cyan)
                    Text("AmeNige")
                        .font(.caption.bold())
                }

                Spacer()

                Image(systemName: entry.level.systemImageName)
                    .font(.largeTitle)
                    .foregroundStyle(levelColor)

                Text(entry.level.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // 右: 判定
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.verdictTitle)
                    .font(.subheadline.bold())

                if let minutes = entry.minutesUntilRain {
                    Label("雨まで\(minutes)分", systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if let dryStart = entry.nextDryWindowStart {
                    Label("晴れ間 \(dryStart)", systemImage: "sun.max.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                Spacer()

                Text(String(format: "%.1f mm/h", entry.currentIntensity))
                    .font(.caption.monospacedDigit())
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
                Image(systemName: entry.isRaining ? "umbrella.fill" : "sun.max.fill")
                    .font(.caption)
                if let minutes = entry.minutesUntilRain {
                    Text("\(minutes)")
                        .font(.title3.bold())
                    Text("分")
                        .font(.system(size: 8))
                } else {
                    Text(entry.isRaining ? "雨" : "晴")
                        .font(.caption.bold())
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Rectangular

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "umbrella.fill")
                Text("AmeNige")
                    .font(.caption.bold())
            }
            Text(entry.verdictTitle)
                .font(.caption2)
            if let minutes = entry.minutesUntilRain {
                Text("雨まであと\(minutes)分")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Inline

    private var inlineView: some View {
        HStack {
            Image(systemName: entry.isRaining ? "umbrella.fill" : "sun.max.fill")
            if let minutes = entry.minutesUntilRain {
                Text("雨まで\(minutes)分")
            } else {
                Text(entry.verdictTitle)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var levelColor: Color {
        switch entry.level {
        case .none: .green
        case .light: .cyan
        case .moderate: .blue
        case .heavy: .orange
        case .veryHeavy: .red
        case .extreme: .purple
        }
    }
}

// MARK: - Widget

struct AmeNigePrecipitationWidget: Widget {
    let kind: String = "AmeNigePrecipitationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrecipitationWidgetProvider()) { entry in
            PrecipitationWidgetView(entry: entry)
        }
        .configurationDisplayName("AmeNige 降水予報")
        .description("現在の降水状況と外出判定を表示")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
