import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

/// ウィジェットに表示するクエストデータ
struct QuestWidgetEntry: TimelineEntry {
    let date: Date
    let heroName: String
    let heroClass: String
    let level: Int
    let hp: Int
    let maxHP: Int
    let mp: Int
    let maxMP: Int
    let gold: Int
    let locationName: String
    let locationEmoji: String
    let dayCount: Int
    let eventTitle: String
    let eventEmoji: String
    let nextEventInterval: TimeInterval
}

// MARK: - Timeline Provider

/// クエストデータを供給する TimelineProvider
struct QuestWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.example.widgetquest"

    func placeholder(in context: Context) -> QuestWidgetEntry {
        QuestWidgetEntry(
            date: Date(),
            heroName: "アレス",
            heroClass: "⚔️",
            level: 1,
            hp: 100,
            maxHP: 100,
            mp: 30,
            maxMP: 30,
            gold: 0,
            locationName: "はじまりの草原",
            locationEmoji: "🌿",
            dayCount: 1,
            eventTitle: "冒険を始めよう！",
            eventEmoji: "🗺️",
            nextEventInterval: 7200
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuestWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuestWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // 2時間後に再取得（イベント間隔に合わせる）
        let nextUpdate = Date().addingTimeInterval(7200)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> QuestWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let name = defaults?.string(forKey: "heroData_name") ?? "アレス"
        let level = defaults?.integer(forKey: "heroData_level") ?? 1
        let hp = defaults?.integer(forKey: "heroData_hp") ?? 100
        let maxHP = defaults?.integer(forKey: "heroData_maxHP") ?? 100
        let mp = defaults?.integer(forKey: "heroData_mp") ?? 30
        let maxMP = defaults?.integer(forKey: "heroData_maxMP") ?? 30
        let gold = defaults?.integer(forKey: "heroData_gold") ?? 0
        let dayCount = defaults?.integer(forKey: "heroData_dayCount") ?? 1

        let classEmoji: String
        if let classRaw = defaults?.string(forKey: "heroData_class") {
            switch classRaw {
            case "戦士": classEmoji = "⚔️"
            case "魔法使い": classEmoji = "🔮"
            case "盗賊": classEmoji = "🗡️"
            case "僧侶": classEmoji = "✝️"
            default: classEmoji = "⚔️"
            }
        } else {
            classEmoji = "⚔️"
        }

        return QuestWidgetEntry(
            date: Date(),
            heroName: name,
            heroClass: classEmoji,
            level: level,
            hp: hp,
            maxHP: maxHP,
            mp: mp,
            maxMP: maxMP,
            gold: gold,
            locationName: "はじまりの草原",
            locationEmoji: "🌿",
            dayCount: dayCount,
            eventTitle: "新たなイベント発生中！",
            eventEmoji: "⚔️",
            nextEventInterval: 7200
        )
    }
}

// MARK: - AppIntent（戦うボタン）

/// ウィジェットからバトルを実行するインテント
struct QuickBattleIntent: AppIntent {
    static var title: LocalizedStringResource = "クイックバトル"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.widgetquest")
        let currentHP = defaults?.integer(forKey: "heroData_hp") ?? 100
        let currentGold = defaults?.integer(forKey: "heroData_gold") ?? 0
        let currentExp = defaults?.integer(forKey: "heroData_experience") ?? 0

        // バトル結果の適用
        let damage = Int.random(in: 5...15)
        let goldReward = Int.random(in: 10...30)
        let expReward = Int.random(in: 10...25)

        defaults?.set(max(0, currentHP - damage), forKey: "heroData_hp")
        defaults?.set(currentGold + goldReward, forKey: "heroData_gold")
        defaults?.set(currentExp + expReward, forKey: "heroData_experience")

        return .result()
    }
}

// MARK: - Widget Views

/// ウィジェットの表示
struct QuestWidgetView: View {
    var entry: QuestWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
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
        VStack(spacing: 6) {
            HStack {
                Text(entry.heroClass)
                    .font(.body)
                Text("Lv.\(entry.level)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            Text(entry.heroName)
                .font(.caption)
                .fontWeight(.semibold)

            // HP Bar
            HStack(spacing: 4) {
                Text("HP")
                    .font(.system(size: 8))
                    .fontWeight(.bold)
                miniBar(value: entry.hp, max: entry.maxHP, color: .red)
            }

            // MP Bar
            HStack(spacing: 4) {
                Text("MP")
                    .font(.system(size: 8))
                    .fontWeight(.bold)
                miniBar(value: entry.mp, max: entry.maxMP, color: .blue)
            }

            Button(intent: QuickBattleIntent()) {
                Label("戦う", systemImage: "bolt.fill")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .controlSize(.mini)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 勇者表示
            VStack(spacing: 4) {
                Text(entry.heroClass)
                    .font(.title2)
                Text("Lv.\(entry.level)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
                Text(entry.heroName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(width: 70)

            // ステータス
            VStack(alignment: .leading, spacing: 6) {
                statusRow(label: "HP", value: entry.hp, max: entry.maxHP, color: .red)
                statusRow(label: "MP", value: entry.mp, max: entry.maxMP, color: .blue)

                HStack(spacing: 8) {
                    Text("💰 \(entry.gold)")
                        .font(.caption2)
                        .monospacedDigit()
                    Text("Day \(entry.dayCount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // イベント
            VStack(spacing: 6) {
                Text(entry.eventEmoji)
                    .font(.title3)

                Button(intent: QuickBattleIntent()) {
                    Text("⚔️")
                        .font(.body)
                }

                Text(entry.locationName)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Large Widget

    private var largeWidget: some View {
        VStack(spacing: 12) {
            // ヘッダー
            HStack {
                Text(entry.locationEmoji)
                    .font(.title2)
                Text("\(entry.locationName) - Day \(entry.dayCount)")
                    .font(.headline)
                Spacer()
            }

            Divider()

            // ステータス
            HStack(spacing: 8) {
                Text(entry.heroClass)
                    .font(.title)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.heroName) Lv.\(entry.level)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    statusRow(label: "HP", value: entry.hp, max: entry.maxHP, color: .red)
                    statusRow(label: "MP", value: entry.mp, max: entry.maxMP, color: .blue)
                }
            }

            Text("💰 Gold: \(entry.gold)")
                .font(.caption)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // イベント
            VStack(spacing: 8) {
                Text("\(entry.eventEmoji) \(entry.eventTitle)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    Button(intent: QuickBattleIntent()) {
                        Label("戦う", systemImage: "bolt.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
            }

            Spacer()

            Text("次のイベント: 2:00:00 後")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Widgets

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Text(entry.heroClass)
                    .font(.system(size: 16))
                Text("Lv\(entry.level)")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(entry.heroClass)
                    .font(.caption)
                Text("\(entry.heroName) Lv.\(entry.level)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            Text("HP: \(entry.hp)/\(entry.maxHP)  MP: \(entry.mp)/\(entry.maxMP)")
                .font(.caption2)
                .monospacedDigit()
            Text("\(entry.locationEmoji) \(entry.locationName)")
                .font(.caption2)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var inlineWidget: some View {
        Text("\(entry.heroClass) Lv.\(entry.level) HP:\(entry.hp) \(entry.locationEmoji)")
            .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Helpers

    private func miniBar(value: Int, max: Int, color: Color) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray4))
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(value) / CGFloat(max), height: 4)
            }
        }
        .frame(height: 4)
    }

    private func statusRow(label: String, value: Int, max: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .frame(width: 20, alignment: .leading)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray4))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / CGFloat(max), height: 6)
                }
            }
            .frame(height: 6)
            Text("\(value)")
                .font(.caption2)
                .monospacedDigit()
                .frame(width: 24, alignment: .trailing)
        }
    }
}

// MARK: - Widget Definition

struct WidgetQuestWidget: Widget {
    let kind: String = "WidgetQuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuestWidgetProvider()) { entry in
            QuestWidgetView(entry: entry)
        }
        .configurationDisplayName("WidgetQuest")
        .description("ウィジェットだけで冒険を楽しめるミニ RPG")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
