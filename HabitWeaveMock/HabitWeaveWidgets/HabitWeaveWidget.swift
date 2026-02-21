import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

/// ウィジェットに表示する習慣データ
struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let activeHabitCount: Int
    let completionRate: Double
    let scheduledCount: Int
    let nextHabitTitle: String
    let nextHabitEmoji: String
    let nextHabitTime: String
    let streakDays: Int
}

// MARK: - Timeline Provider

/// 習慣データを供給する TimelineProvider
struct HabitWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.example.habitweave"

    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            activeHabitCount: 4,
            completionRate: 0.75,
            scheduledCount: 3,
            nextHabitTitle: "読書",
            nextHabitEmoji: "📚",
            nextHabitTime: "19:00",
            streakDays: 5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // 1時間後に再取得
        let nextUpdate = Date().addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> HabitWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let activeCount = defaults?.integer(forKey: "activeHabitCount") ?? 4
        let rate = defaults?.double(forKey: "completionRate") ?? 0.75
        let scheduledCount = defaults?.integer(forKey: "scheduledCount") ?? 3
        let nextTitle = defaults?.string(forKey: "nextHabitTitle") ?? "読書"
        let nextEmoji = defaults?.string(forKey: "nextHabitEmoji") ?? "📚"
        let nextTime = defaults?.string(forKey: "nextHabitTime") ?? "19:00"

        return HabitWidgetEntry(
            date: Date(),
            activeHabitCount: activeCount,
            completionRate: rate,
            scheduledCount: scheduledCount,
            nextHabitTitle: nextTitle,
            nextHabitEmoji: nextEmoji,
            nextHabitTime: nextTime,
            streakDays: 5
        )
    }
}

// MARK: - AppIntent（習慣完了）

/// ウィジェットから習慣を完了するインテント
struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "習慣を完了"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.habitweave")
        let currentRate = defaults?.double(forKey: "completionRate") ?? 0
        let newRate = min(1.0, currentRate + 0.25)
        defaults?.set(newRate, forKey: "completionRate")
        return .result()
    }
}

// MARK: - Widget View

/// ウィジェットの表示
struct HabitWidgetView: View {
    var entry: HabitWidgetEntry
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

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(spacing: 8) {
            // 達成率リング
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 5)
                    .frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: entry.completionRate)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(entry.completionRate * 100))%")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            Text("今日の達成率")
                .font(.caption2)
                .foregroundStyle(.secondary)

            // 次の習慣
            HStack(spacing: 4) {
                Text(entry.nextHabitEmoji)
                    .font(.caption2)
                Text(entry.nextHabitTime)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }

            Button(intent: CompleteHabitIntent()) {
                Label("完了", systemImage: "checkmark")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.mini)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 達成率
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 5)
                        .frame(width: 56, height: 56)
                    Circle()
                        .trim(from: 0, to: entry.completionRate)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(entry.completionRate * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
                Text("達成率")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // 情報
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("📋")
                        .font(.caption2)
                    Text("アクティブ: \(entry.activeHabitCount)件")
                        .font(.caption)
                }
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.caption2)
                    Text("連続: \(entry.streakDays)日")
                        .font(.caption)
                }
                HStack(spacing: 4) {
                    Text(entry.nextHabitEmoji)
                        .font(.caption2)
                    Text("次: \(entry.nextHabitTitle) \(entry.nextHabitTime)")
                        .font(.caption)
                        .lineLimit(1)
                }
            }

            Spacer()

            // アクション
            VStack(spacing: 8) {
                Button(intent: CompleteHabitIntent()) {
                    Text("✅")
                        .font(.title3)
                }

                Text("完了")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Widgets

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Text("\(Int(entry.completionRate * 100))%")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                Text("達成")
                    .font(.system(size: 8))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("🌿 HabitWeave")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Text("\(Int(entry.completionRate * 100))%")
                    .font(.caption)
                    .monospacedDigit()
            }
            Text("\(entry.nextHabitEmoji) \(entry.nextHabitTitle) \(entry.nextHabitTime)")
                .font(.caption2)
            Text("🔥 \(entry.streakDays)日連続達成中")
                .font(.caption2)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var inlineWidget: some View {
        Text("🌿 達成 \(Int(entry.completionRate * 100))% 🔥\(entry.streakDays)日")
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct HabitWeaveWidget: Widget {
    let kind: String = "HabitWeaveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitWidgetView(entry: entry)
        }
        .configurationDisplayName("HabitWeave")
        .description("習慣の達成状況と次のスケジュールを確認できます")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
