import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

/// ウィジェットに表示する植物ケアデータ
struct PlantCareEntry: TimelineEntry {
    let date: Date
    let plantName: String
    let plantEmoji: String
    let healthScore: Int
    let needsWatering: Bool
    let wateringDaysLeft: Int
    let totalPlants: Int
    let plantsNeedingCare: Int
}

// MARK: - Timeline Provider

/// 植物ケアデータを供給する TimelineProvider
struct PlantCareProvider: TimelineProvider {
    private let appGroupID = "group.com.example.plantdoctor"

    func placeholder(in context: Context) -> PlantCareEntry {
        PlantCareEntry(
            date: Date(),
            plantName: "モンステラ",
            plantEmoji: "🪴",
            healthScore: 85,
            needsWatering: false,
            wateringDaysLeft: 3,
            totalPlants: 3,
            plantsNeedingCare: 1
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PlantCareEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlantCareEntry>) -> Void) {
        let entry = loadEntry()
        // 1時間後に再取得
        let nextUpdate = Date().addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> PlantCareEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let plantName = defaults?.string(forKey: "topPlantName") ?? "モンステラ"
        let plantEmoji = defaults?.string(forKey: "topPlantEmoji") ?? "🪴"
        let healthScore = defaults?.integer(forKey: "topPlantHealth") != 0
            ? defaults!.integer(forKey: "topPlantHealth") : 85
        let wateringDays = defaults?.integer(forKey: "topPlantWateringDays") ?? 3
        let totalPlants = defaults?.integer(forKey: "totalPlants") != 0
            ? defaults!.integer(forKey: "totalPlants") : 3
        let needingCare = defaults?.integer(forKey: "plantsNeedingCare") ?? 1

        return PlantCareEntry(
            date: Date(),
            plantName: plantName,
            plantEmoji: plantEmoji,
            healthScore: healthScore,
            needsWatering: wateringDays <= 0,
            wateringDaysLeft: wateringDays,
            totalPlants: totalPlants,
            plantsNeedingCare: needingCare
        )
    }
}

// MARK: - AppIntent（水やり記録）

/// ウィジェットから水やりを記録するインテント
struct RecordWateringIntent: AppIntent {
    static var title: LocalizedStringResource = "水やりを記録"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.plantdoctor")
        defaults?.set(Date().timeIntervalSince1970, forKey: "lastWateredTimestamp")
        let current = defaults?.integer(forKey: "plantsNeedingCare") ?? 1
        defaults?.set(max(0, current - 1), forKey: "plantsNeedingCare")
        return .result()
    }
}

// MARK: - Widget View

/// 植物ケアウィジェットの表示
struct PlantCareWidgetView: View {
    var entry: PlantCareEntry
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
            HStack {
                Text(entry.plantEmoji)
                    .font(.title)
                Spacer()
                Text("\(entry.healthScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(healthColor)
            }

            Text(entry.plantName)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            if entry.needsWatering {
                Button(intent: RecordWateringIntent()) {
                    Label("水やり", systemImage: "drop.fill")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.mini)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text("あと\(entry.wateringDaysLeft)日")
                        .font(.caption)
                        .monospacedDigit()
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // メイン植物
            VStack(spacing: 6) {
                Text(entry.plantEmoji)
                    .font(.system(size: 40))
                Text(entry.plantName)
                    .font(.caption)
                    .fontWeight(.medium)

                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 4)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.healthScore) / 100)
                        .stroke(healthColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    Text("\(entry.healthScore)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }

            // サマリー
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                    Text("\(entry.totalPlants)つの植物")
                        .font(.subheadline)
                }

                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(.blue)
                    Text(entry.needsWatering ? "水やりが必要" : "あと\(entry.wateringDaysLeft)日")
                        .font(.subheadline)
                }

                if entry.plantsNeedingCare > 0 {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                        Text("\(entry.plantsNeedingCare)つ要ケア")
                            .font(.subheadline)
                    }
                }
            }

            Spacer()

            // 水やりボタン
            if entry.needsWatering {
                Button(intent: RecordWateringIntent()) {
                    VStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.title3)
                        Text("水やり")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Widgets

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Text(entry.plantEmoji)
                    .font(.system(size: 16))
                Text("\(entry.healthScore)")
                    .font(.system(size: 12, weight: .bold))
                    .monospacedDigit()
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(entry.plantEmoji)
                Text(entry.plantName)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            HStack(spacing: 8) {
                Text("💚 \(entry.healthScore)")
                    .font(.caption2)
                Text("💧 \(entry.needsWatering ? "必要" : "あと\(entry.wateringDaysLeft)日")")
                    .font(.caption2)
            }
            Text("🌿 \(entry.totalPlants)つ管理中")
                .font(.caption2)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var inlineWidget: some View {
        Text("\(entry.plantEmoji) \(entry.plantName) 💚\(entry.healthScore) 💧\(entry.wateringDaysLeft)日")
            .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Helpers

    private var healthColor: Color {
        if entry.healthScore >= 80 { return .green }
        if entry.healthScore >= 60 { return .yellow }
        return .red
    }
}

// MARK: - Widget Definition

struct PlantDoctorCareWidget: Widget {
    let kind: String = "PlantDoctorCareWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantCareProvider()) { entry in
            PlantCareWidgetView(entry: entry)
        }
        .configurationDisplayName("PlantDoctor")
        .description("植物の健康状態と水やりスケジュールを表示します")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
