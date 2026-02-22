import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct SocialPulseEntry: TimelineEntry {
    let date: Date
    let overallScore: Int
    let phoneScore: Int
    let messageScore: Int
    let visitScore: Int
    let scoreLevel: String
    let trend: String
    let assessmentText: String
}

// MARK: - Timeline Provider

struct SocialPulseProvider: TimelineProvider {
    func placeholder(in context: Context) -> SocialPulseEntry {
        SocialPulseEntry(
            date: Date(),
            overallScore: 75,
            phoneScore: 72,
            messageScore: 85,
            visitScore: 68,
            scoreLevel: "良好",
            trend: "改善傾向",
            assessmentText: "社会的つながりは良好です"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SocialPulseEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SocialPulseEntry>) -> Void) {
        let overallScore = Int.random(in: 55...90)
        let level = SocialLevel.from(score: overallScore)
        let entry = SocialPulseEntry(
            date: Date(),
            overallScore: overallScore,
            phoneScore: Int.random(in: 40...95),
            messageScore: Int.random(in: 50...95),
            visitScore: Int.random(in: 35...90),
            scoreLevel: level.rawValue,
            trend: ["改善傾向", "安定", "低下傾向"].randomElement()!,
            assessmentText: level == .excellent || level == .good
                ? "社会的つながりは良好です"
                : "社会的つながりがやや低下しています"
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Views

struct SocialPulseWidgetEntryView: View {
    var entry: SocialPulseEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - System Small

private struct SmallWidgetView: View {
    let entry: SocialPulseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundStyle(.pink)
                Text("Social Pulse")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 6)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: Double(entry.overallScore) / 100.0)
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 64, height: 64)
                Text("\(entry.overallScore)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            Text("社会的つながり")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var scoreColor: Color {
        switch entry.overallScore {
        case 80...: .green
        case 60..<80: .blue
        case 40..<60: .orange
        default: .red
        }
    }
}

// MARK: - System Medium

private struct MediumWidgetView: View {
    let entry: SocialPulseEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "heart.circle.fill")
                        .foregroundStyle(.pink)
                    Text("Social Pulse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(entry.overallScore)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                Text(entry.scoreLevel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                MediumStatRow(
                    icon: "phone.fill",
                    label: "電話",
                    value: "\(entry.phoneScore)",
                    color: .blue
                )
                MediumStatRow(
                    icon: "message.fill",
                    label: "メッセージ",
                    value: "\(entry.messageScore)",
                    color: .green
                )
                MediumStatRow(
                    icon: "mappin.and.ellipse",
                    label: "訪問",
                    value: "\(entry.visitScore)",
                    color: .orange
                )
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

private struct MediumStatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
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

// MARK: - Accessory Circular

private struct CircularWidgetView: View {
    let entry: SocialPulseEntry

    var body: some View {
        Gauge(value: Double(entry.overallScore), in: 0...100) {
            Image(systemName: "heart.circle.fill")
        } currentValueLabel: {
            Text("\(entry.overallScore)")
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Accessory Rectangular

private struct RectangularWidgetView: View {
    let entry: SocialPulseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "heart.circle.fill")
                    .font(.caption2)
                Text("Social Pulse")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }

            HStack(spacing: 6) {
                Text("\(entry.overallScore)")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.scoreLevel)
                        .font(.caption2)
                    Text(entry.trend)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Accessory Inline

private struct InlineWidgetView: View {
    let entry: SocialPulseEntry

    var body: some View {
        Text("Social Pulse: \(entry.overallScore)/100")
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct SocialPulseWidget: Widget {
    let kind = "SocialPulseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SocialPulseProvider()) { entry in
            SocialPulseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Social Pulse")
        .description("社会的つながりスコアを表示します")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
