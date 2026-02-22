import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct FoodLogEntry: TimelineEntry {
    let date: Date
    let totalCalories: Int
    let targetCalories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let mealCount: Int
}

// MARK: - Timeline Provider

struct FoodLogProvider: TimelineProvider {
    func placeholder(in context: Context) -> FoodLogEntry {
        FoodLogEntry(
            date: Date(),
            totalCalories: 1450,
            targetCalories: 2200,
            protein: 58.5,
            fat: 42.0,
            carbs: 185.0,
            mealCount: 2
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FoodLogEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FoodLogEntry>) -> Void) {
        let entry = FoodLogEntry(
            date: Date(),
            totalCalories: Int.random(in: 800...2000),
            targetCalories: 2200,
            protein: Double.random(in: 30...80),
            fat: Double.random(in: 20...60),
            carbs: Double.random(in: 100...250),
            mealCount: Int.random(in: 1...3)
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Views

struct FoodLogWidgetEntryView: View {
    var entry: FoodLogEntry
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
    let entry: FoodLogEntry

    private var progress: Double {
        guard entry.targetCalories > 0 else { return 0 }
        return min(1.0, Double(entry.totalCalories) / Double(entry.targetCalories))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.orange)
                Text("FoodLog")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(entry.totalCalories)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .frame(width: 60, height: 60)

            Text("\(entry.targetCalories - entry.totalCalories) kcal 残り")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

private struct MediumWidgetView: View {
    let entry: FoodLogEntry

    private var progress: Double {
        guard entry.targetCalories > 0 else { return 0 }
        return min(1.0, Double(entry.totalCalories) / Double(entry.targetCalories))
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.orange)
                    Text("FoodLog AI")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(entry.totalCalories)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text("/ \(entry.targetCalories) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                PFCWidgetRow(label: "P", value: entry.protein, color: .red)
                PFCWidgetRow(label: "F", value: entry.fat, color: .yellow)
                PFCWidgetRow(label: "C", value: entry.carbs, color: .blue)
                Spacer()
                Text("\(entry.mealCount) 食記録済み")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

private struct PFCWidgetRow: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .frame(width: 12)
            Text(String(format: "%.0fg", value))
                .font(.caption)
        }
    }
}

private struct CircularWidgetView: View {
    let entry: FoodLogEntry

    private var progress: Double {
        guard entry.targetCalories > 0 else { return 0 }
        return min(1.0, Double(entry.totalCalories) / Double(entry.targetCalories))
    }

    var body: some View {
        Gauge(value: progress) {
            Image(systemName: "fork.knife")
        } currentValueLabel: {
            Text("\(entry.totalCalories)")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct FoodLogAIWidget: Widget {
    let kind = "FoodLogAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FoodLogProvider()) { entry in
            FoodLogWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FoodLog AI")
        .description("今日のカロリー摂取量とPFCバランスを表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}
