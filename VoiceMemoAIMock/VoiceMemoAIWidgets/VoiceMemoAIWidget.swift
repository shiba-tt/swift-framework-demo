import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct VoiceMemoAIWidgetEntry: TimelineEntry {
    let date: Date
    let latestMemoTitle: String
    let latestMemoCategory: String
    let latestMemoCategoryEmoji: String
    let pendingActionItems: Int
    let totalMemos: Int
    let todayMemos: Int
}

// MARK: - Timeline Provider

struct VoiceMemoAIWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.example.voicememoai"

    func placeholder(in context: Context) -> VoiceMemoAIWidgetEntry {
        VoiceMemoAIWidgetEntry(
            date: Date(),
            latestMemoTitle: "チーム定例ミーティング",
            latestMemoCategory: "会議メモ",
            latestMemoCategoryEmoji: "🏢",
            pendingActionItems: 3,
            totalMemos: 12,
            todayMemos: 2
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (VoiceMemoAIWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VoiceMemoAIWidgetEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: appGroupID)
        let entry = VoiceMemoAIWidgetEntry(
            date: Date(),
            latestMemoTitle: defaults?.string(forKey: "latestMemoTitle") ?? "メモなし",
            latestMemoCategory: defaults?.string(forKey: "latestMemoCategory") ?? "その他",
            latestMemoCategoryEmoji: defaults?.string(forKey: "latestMemoCategoryEmoji") ?? "📋",
            pendingActionItems: defaults?.integer(forKey: "pendingActionItems") ?? 0,
            totalMemos: defaults?.integer(forKey: "totalMemos") ?? 0,
            todayMemos: defaults?.integer(forKey: "todayMemos") ?? 0
        )

        let nextUpdate = Date().addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View

struct VoiceMemoAIWidgetView: View {
    var entry: VoiceMemoAIWidgetEntry
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.indigo)
                Text("VoiceMemo")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.indigo)
            }

            Spacer()

            Text(entry.latestMemoCategoryEmoji)
                .font(.title2)
            Text(entry.latestMemoTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)

            if entry.pendingActionItems > 0 {
                Label("未完了 \(entry.pendingActionItems)件", systemImage: "checklist")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 左: 最新メモ情報
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(.indigo)
                    Text("VoiceMemo AI")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.indigo)
                }

                Spacer()

                HStack(spacing: 6) {
                    Text(entry.latestMemoCategoryEmoji)
                    Text(entry.latestMemoCategory)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(entry.latestMemoTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 右: 統計
            VStack(spacing: 8) {
                Spacer()
                StatMiniBox(value: "\(entry.totalMemos)", label: "総メモ", color: .indigo)
                StatMiniBox(value: "\(entry.todayMemos)", label: "今日", color: .blue)
                if entry.pendingActionItems > 0 {
                    StatMiniBox(value: "\(entry.pendingActionItems)", label: "未完了", color: .orange)
                }
                Spacer()
            }
        }
        .padding(4)
    }

    // MARK: - Circular Widget

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "mic.fill")
                    .font(.title3)
                Text("\(entry.totalMemos)")
                    .font(.headline)
            }
        }
    }

    // MARK: - Rectangular Widget

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "mic.fill")
                Text("VoiceMemo")
                    .fontWeight(.semibold)
            }
            .font(.caption)

            Text(entry.latestMemoTitle)
                .font(.caption2)
                .lineLimit(1)

            if entry.pendingActionItems > 0 {
                Text("未完了: \(entry.pendingActionItems)件")
                    .font(.caption2)
            }
        }
    }

    // MARK: - Inline Widget

    private var inlineWidget: some View {
        Label("メモ \(entry.totalMemos)件", systemImage: "mic.fill")
    }
}

// MARK: - StatMiniBox

struct StatMiniBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 56)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Widget Definition

struct VoiceMemoAIWidget: Widget {
    let kind: String = "VoiceMemoAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VoiceMemoAIWidgetProvider()) { entry in
            VoiceMemoAIWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("VoiceMemo AI")
        .description("最新の音声メモとアクションアイテムを確認")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
