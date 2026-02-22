import SwiftUI
import WidgetKit

/// タイピングバイオマーカーウィジェット
struct TypeGuardWidget: Widget {
    let kind = "TypeGuardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TypeGuardProvider()) { entry in
            TypeGuardWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TypeGuard")
        .description("タイピングバイオマーカーの状態を表示します。")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

// MARK: - Timeline Entry

struct TypeGuardEntry: TimelineEntry {
    let date: Date
    let riskScore: Int
    let riskLevel: String
    let averageWPM: Double
    let errorRate: Double
    let baselineEstablished: Bool
}

// MARK: - Provider

struct TypeGuardProvider: TimelineProvider {
    func placeholder(in context: Context) -> TypeGuardEntry {
        TypeGuardEntry(
            date: .now,
            riskScore: 15,
            riskLevel: "正常",
            averageWPM: 38.0,
            errorRate: 0.05,
            baselineEstablished: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TypeGuardEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TypeGuardEntry>) -> Void) {
        let entry = TypeGuardEntry(
            date: .now,
            riskScore: 15,
            riskLevel: "正常",
            averageWPM: 38.0,
            errorRate: 0.05,
            baselineEstablished: true
        )
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
        completion(timeline)
    }
}

// MARK: - Widget View

struct TypeGuardWidgetView: View {
    let entry: TypeGuardEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryCircular:
            circularWidget
        case .accessoryRectangular:
            rectangularWidget
        case .accessoryInline:
            inlineWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "keyboard.badge.eye.fill")
                    .foregroundStyle(.teal)
                Text("TypeGuard")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: riskIcon)
                    .font(.title2)
                    .foregroundStyle(riskColor)
                Text(entry.riskLevel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "gauge.with.dots.needle.50percent")
                    .font(.caption2)
                Text(String(format: "%.0f WPM", entry.averageWPM))
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Medium

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "keyboard.badge.eye.fill")
                        .foregroundStyle(.teal)
                    Text("TypeGuard")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: riskIcon)
                        .font(.title)
                        .foregroundStyle(riskColor)
                    VStack(alignment: .leading) {
                        Text(entry.riskLevel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("リスクスコア: \(entry.riskScore)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                MetricMiniRow(icon: "gauge.with.dots.needle.50percent", label: "速度", value: String(format: "%.0f WPM", entry.averageWPM))
                MetricMiniRow(icon: "xmark.circle", label: "エラー", value: String(format: "%.1f%%", entry.errorRate * 100))
                MetricMiniRow(icon: "target", label: "状態", value: entry.baselineEstablished ? "確立済" : "構築中")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Lock Screen

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: riskIcon)
                    .font(.system(size: 16))
                Text("\(entry.riskScore)")
                    .font(.system(size: 10))
            }
        }
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: riskIcon)
                    .font(.system(size: 12))
                Text("TypeGuard")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            Text("\(String(format: "%.0f", entry.averageWPM)) WPM  Err: \(String(format: "%.1f", entry.errorRate * 100))%")
                .font(.caption2)
            Text("リスク: \(entry.riskLevel)")
                .font(.caption2)
        }
    }

    private var inlineWidget: some View {
        Text("\(entry.riskLevel) \(String(format: "%.0f", entry.averageWPM))WPM")
    }

    // MARK: - Helpers

    private var riskIcon: String {
        switch entry.riskScore {
        case ..<25: "checkmark.shield.fill"
        case 25..<50: "exclamationmark.circle.fill"
        case 50..<75: "exclamationmark.triangle.fill"
        default: "xmark.shield.fill"
        }
    }

    private var riskColor: Color {
        switch entry.riskScore {
        case ..<25: .green
        case 25..<50: .yellow
        case 50..<75: .orange
        default: .red
        }
    }
}

private struct MetricMiniRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.teal)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .leading)
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
}
