import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

/// ウィジェットに表示するデータ
struct PetWidgetEntry: TimelineEntry {
    let date: Date
    let petName: String
    let species: String
    let mood: String
    let faceText: String
    let hunger: Int
    let happiness: Int
    let cleanliness: Int
    let energy: Int
    let overallCondition: Int
}

// MARK: - Timeline Provider

/// ペットデータを供給する TimelineProvider
struct PetWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.example.pixelpet"

    func placeholder(in context: Context) -> PetWidgetEntry {
        PetWidgetEntry(
            date: Date(),
            petName: "ぴくせる",
            species: "🐱",
            mood: "ごきげん",
            faceText: "^ω^",
            hunger: 80,
            happiness: 80,
            cleanliness: 80,
            energy: 80,
            overallCondition: 80
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PetWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // 30分後に再取得
        let nextUpdate = Date().addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> PetWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let name = defaults?.string(forKey: "petData_name") ?? "ぴくせる"
        let hunger = defaults?.integer(forKey: "petData_hunger") ?? 50
        let happiness = defaults?.integer(forKey: "petData_happiness") ?? 50
        let cleanliness = defaults?.integer(forKey: "petData_cleanliness") ?? 50
        let energy = defaults?.integer(forKey: "petData_energy") ?? 50
        let overall = (hunger + happiness + cleanliness + energy) / 4

        let mood: String
        let faceText: String
        if overall >= 80 {
            mood = "ごきげん"
            faceText = "^ω^"
        } else if overall >= 60 {
            mood = "ふつう"
            faceText = "・ω・"
        } else if overall >= 40 {
            mood = "さみしい"
            faceText = ";ω;"
        } else {
            mood = "おなかすいた"
            faceText = ">ω<"
        }

        return PetWidgetEntry(
            date: Date(),
            petName: name,
            species: "🐱",
            mood: mood,
            faceText: faceText,
            hunger: hunger,
            happiness: happiness,
            cleanliness: cleanliness,
            energy: energy,
            overallCondition: overall
        )
    }
}

// MARK: - AppIntent（ごはんボタン）

/// ウィジェットからペットにごはんをあげるインテント
struct FeedPetIntent: AppIntent {
    static var title: LocalizedStringResource = "ごはんをあげる"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.pixelpet")
        let current = defaults?.integer(forKey: "petData_hunger") ?? 50
        defaults?.set(min(100, current + 30), forKey: "petData_hunger")
        return .result()
    }
}

// MARK: - Widget View

/// ウィジェットの表示
struct PetWidgetView: View {
    var entry: PetWidgetEntry
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
            Text(entry.species)
                .font(.system(size: 32))
            Text(entry.faceText)
                .font(.system(size: 20, design: .monospaced))
                .fontWeight(.bold)

            HStack(spacing: 4) {
                Text("❤️")
                    .font(.caption2)
                statusMiniBar(value: entry.hunger)
            }

            Button(intent: FeedPetIntent()) {
                Label("ごはん", systemImage: "fork.knife")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .controlSize(.mini)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // ペット表示
            VStack(spacing: 4) {
                Text(entry.species)
                    .font(.system(size: 36))
                Text(entry.faceText)
                    .font(.system(size: 18, design: .monospaced))
                    .fontWeight(.bold)
                Text(entry.petName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 80)

            // ステータス
            VStack(alignment: .leading, spacing: 6) {
                statusRow(emoji: "❤️", label: "満腹度", value: entry.hunger)
                statusRow(emoji: "⭐", label: "機嫌", value: entry.happiness)
                statusRow(emoji: "✨", label: "清潔度", value: entry.cleanliness)
                statusRow(emoji: "⚡", label: "体力", value: entry.energy)
            }

            Spacer()

            // アクションボタン
            VStack(spacing: 8) {
                Button(intent: FeedPetIntent()) {
                    Text("🍖")
                        .font(.title3)
                }

                Text(entry.mood)
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
                Text(entry.faceText)
                    .font(.system(size: 14, design: .monospaced))
                    .fontWeight(.bold)
                Text("\(entry.overallCondition)")
                    .font(.system(size: 10))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(entry.faceText)
                    .font(.system(size: 12, design: .monospaced))
                Text(entry.petName)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            Text("❤️ \(entry.hunger)  ⭐ \(entry.happiness)")
                .font(.caption2)
            Text("✨ \(entry.cleanliness)  ⚡ \(entry.energy)")
                .font(.caption2)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var inlineWidget: some View {
        Text("\(entry.faceText) \(entry.petName) ❤️\(entry.overallCondition)")
            .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Helpers

    private func statusMiniBar(value: Int) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray4))
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 2)
                    .fill(value >= 50 ? Color.green : Color.red)
                    .frame(width: geometry.size.width * CGFloat(value) / 100, height: 4)
            }
        }
        .frame(height: 4)
    }

    private func statusRow(emoji: String, label: String, value: Int) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.caption2)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray4))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(value >= 50 ? Color.green : Color.orange)
                        .frame(width: geometry.size.width * CGFloat(value) / 100, height: 6)
                }
            }
            .frame(height: 6)
            Text("\(value)")
                .font(.caption2)
                .monospacedDigit()
                .frame(width: 20, alignment: .trailing)
        }
    }
}

// MARK: - Widget Definition

struct PixelPetWidget: Widget {
    let kind: String = "PixelPetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetWidgetProvider()) { entry in
            PetWidgetView(entry: entry)
        }
        .configurationDisplayName("PixelPet")
        .description("ペットの様子をホーム画面で確認できます")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
