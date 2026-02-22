import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct MoodWidgetEntry: TimelineEntry {
    let date: Date
    let todayMood: String?
    let todayEmoji: String?
    let streakDays: Int
    let weeklyMoods: [(weekday: String, emoji: String?, score: Int?)]
}

// MARK: - Timeline Provider

struct MoodWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.example.moodboard"

    func placeholder(in context: Context) -> MoodWidgetEntry {
        MoodWidgetEntry(
            date: .now,
            todayMood: "ハッピー",
            todayEmoji: "😊",
            streakDays: 5,
            weeklyMoods: [
                ("月", "😊", 4), ("火", "😌", 3), ("水", "😐", 2),
                ("木", "🔥", 5), ("金", "😌", 3), ("土", "😊", 4), ("日", nil, nil),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodWidgetEntry>) -> Void) {
        let entry = loadEntry()

        // 翌日 0:00 にリセット
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func loadEntry() -> MoodWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)

        // 今日の気分
        var todayMood: String?
        var todayEmoji: String?

        if let moodRaw = defaults?.string(forKey: "todayMood") {
            let dateInterval = defaults?.double(forKey: "todayMoodDate") ?? 0
            let moodDate = Date(timeIntervalSince1970: dateInterval)

            if Calendar.current.isDateInToday(moodDate) {
                let moodInfo = moodDisplayInfo(moodRaw)
                todayMood = moodInfo.name
                todayEmoji = moodInfo.emoji
            }
        }

        // 連続記録日数
        let streak = defaults?.integer(forKey: "streakDays") ?? 0

        // 週間データ（簡易）
        let weeklyMoods: [(weekday: String, emoji: String?, score: Int?)] = [
            ("月", "😊", 4), ("火", "😌", 3), ("水", "😐", 2),
            ("木", "🔥", 5), ("金", "😌", 3), ("土", todayEmoji, todayEmoji != nil ? 4 : nil), ("日", nil, nil),
        ]

        return MoodWidgetEntry(
            date: .now,
            todayMood: todayMood,
            todayEmoji: todayEmoji,
            streakDays: streak,
            weeklyMoods: weeklyMoods
        )
    }

    private func moodDisplayInfo(_ rawValue: String) -> (name: String, emoji: String) {
        switch rawValue {
        case "happy": ("ハッピー", "😊")
        case "good": ("いい感じ", "😌")
        case "neutral": ("ふつう", "😐")
        case "sad": ("しょんぼり", "😔")
        case "fire": ("やる気満々", "🔥")
        default: ("ふつう", "😐")
        }
    }
}

// MARK: - AppIntents（気分記録ボタン）

struct RecordHappyIntent: AppIntent {
    static var title: LocalizedStringResource = "ハッピー"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.moodboard")
        defaults?.set("happy", forKey: "todayMood")
        defaults?.set(Date().timeIntervalSince1970, forKey: "todayMoodDate")
        return .result()
    }
}

struct RecordGoodIntent: AppIntent {
    static var title: LocalizedStringResource = "いい感じ"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.moodboard")
        defaults?.set("good", forKey: "todayMood")
        defaults?.set(Date().timeIntervalSince1970, forKey: "todayMoodDate")
        return .result()
    }
}

struct RecordNeutralIntent: AppIntent {
    static var title: LocalizedStringResource = "ふつう"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.moodboard")
        defaults?.set("neutral", forKey: "todayMood")
        defaults?.set(Date().timeIntervalSince1970, forKey: "todayMoodDate")
        return .result()
    }
}

struct RecordSadIntent: AppIntent {
    static var title: LocalizedStringResource = "しょんぼり"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.moodboard")
        defaults?.set("sad", forKey: "todayMood")
        defaults?.set(Date().timeIntervalSince1970, forKey: "todayMoodDate")
        return .result()
    }
}

struct RecordFireIntent: AppIntent {
    static var title: LocalizedStringResource = "やる気満々"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.moodboard")
        defaults?.set("fire", forKey: "todayMood")
        defaults?.set(Date().timeIntervalSince1970, forKey: "todayMoodDate")
        return .result()
    }
}

// MARK: - Widget View

struct MoodWidgetView: View {
    var entry: MoodWidgetEntry
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
            if let emoji = entry.todayEmoji, let mood = entry.todayMood {
                Text(emoji)
                    .font(.system(size: 36))
                Text(mood)
                    .font(.caption)
                    .fontWeight(.medium)
            } else {
                Text("今の気分は？")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Button(intent: RecordHappyIntent()) {
                    Text("😊")
                        .font(.system(size: 18))
                }
                Button(intent: RecordNeutralIntent()) {
                    Text("😐")
                        .font(.system(size: 18))
                }
                Button(intent: RecordSadIntent()) {
                    Text("😔")
                        .font(.system(size: 18))
                }
            }
            .buttonStyle(.plain)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 今日の気分 + ボタン
            VStack(spacing: 8) {
                if let emoji = entry.todayEmoji {
                    Text(emoji)
                        .font(.system(size: 32))
                    Text(entry.todayMood ?? "")
                        .font(.caption2)
                        .fontWeight(.medium)
                } else {
                    Text("今の気分は？")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Button(intent: RecordHappyIntent()) {
                        Text("😊").font(.system(size: 16))
                    }
                    Button(intent: RecordGoodIntent()) {
                        Text("😌").font(.system(size: 16))
                    }
                    Button(intent: RecordNeutralIntent()) {
                        Text("😐").font(.system(size: 16))
                    }
                    Button(intent: RecordSadIntent()) {
                        Text("😔").font(.system(size: 16))
                    }
                    Button(intent: RecordFireIntent()) {
                        Text("🔥").font(.system(size: 16))
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(width: 100)

            Divider()

            // 週間ムードグラフ
            VStack(alignment: .leading, spacing: 4) {
                Text("今週のムード")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(entry.weeklyMoods.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 2) {
                            if let emoji = item.emoji {
                                Text(emoji)
                                    .font(.system(size: 12))
                            } else {
                                Text("—")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.tertiary)
                            }

                            RoundedRectangle(cornerRadius: 2)
                                .fill(barColor(score: item.score).gradient)
                                .frame(height: CGFloat(item.score ?? 1) / 5 * 30)

                            Text(item.weekday)
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 60)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Widgets

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                if let emoji = entry.todayEmoji {
                    Text(emoji)
                        .font(.system(size: 16))
                } else {
                    Text("😊")
                        .font(.system(size: 16))
                        .opacity(0.3)
                }
                Text("\(entry.streakDays)日")
                    .font(.system(size: 9))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(entry.todayEmoji ?? "—")
                    .font(.system(size: 14))
                Text("MoodBoard")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            if let mood = entry.todayMood {
                Text("今日: \(mood)")
                    .font(.caption2)
            } else {
                Text("今日はまだ記録なし")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text("連続 \(entry.streakDays)日目")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var inlineWidget: some View {
        Text("\(entry.todayEmoji ?? "📝") \(entry.todayMood ?? "未記録") 連続\(entry.streakDays)日")
            .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Helpers

    private func barColor(score: Int?) -> Color {
        guard let score else { return Color(.systemGray5) }
        switch score {
        case 4...: .yellow
        case 3: .green
        case 2: .gray
        default: .blue
        }
    }
}

// MARK: - Widget Definition

struct MoodBoardWidget: Widget {
    let kind: String = "MoodBoardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoodWidgetProvider()) { entry in
            MoodWidgetView(entry: entry)
        }
        .configurationDisplayName("MoodBoard")
        .description("気分を記録してムードの推移を確認できます")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
