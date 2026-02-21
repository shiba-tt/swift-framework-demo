import WidgetKit
import SwiftUI

// MARK: - PedalBoardWidget

struct PedalBoardWidget: Widget {
    let kind = "PedalBoardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PedalBoardWidgetProvider()) { entry in
            PedalBoardWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PedalBoard")
        .description("現在のペダルボード構成を表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Widget Entry

struct PedalBoardWidgetEntry: TimelineEntry {
    let date: Date
    let presetName: String?
    let pedalEmojis: [String]
    let enabledCount: Int
    let totalCount: Int
    let isEngineRunning: Bool
}

// MARK: - Widget Provider

struct PedalBoardWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PedalBoardWidgetEntry {
        PedalBoardWidgetEntry(
            date: .now,
            presetName: "Classic Rock",
            pedalEmojis: ["🚪", "🔥", "🎛️", "🔄"],
            enabledCount: 4,
            totalCount: 4,
            isEngineRunning: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PedalBoardWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PedalBoardWidgetEntry>) -> Void) {
        let entry = PedalBoardWidgetEntry(
            date: .now,
            presetName: nil,
            pedalEmojis: [],
            enabledCount: 0,
            totalCount: 0,
            isEngineRunning: false
        )

        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Widget View

struct PedalBoardWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PedalBoardWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryCircular:
            circularWidget
        case .accessoryRectangular:
            rectangularWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "guitars.fill")
                    .foregroundStyle(.orange)
                Spacer()
                Circle()
                    .fill(entry.isEngineRunning ? .green : .red)
                    .frame(width: 8, height: 8)
            }

            Spacer()

            if let presetName = entry.presetName {
                Text(presetName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            } else {
                Text("未設定")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // ペダルアイコン列
            HStack(spacing: 2) {
                ForEach(entry.pedalEmojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.caption)
                }
            }

            Text("\(entry.enabledCount)/\(entry.totalCount) ON")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(4)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 左側: プリセット情報
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "guitars.fill")
                        .foregroundStyle(.orange)
                    Text("PedalBoard")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                Spacer()

                Text(entry.presetName ?? "カスタム")
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Text("\(entry.enabledCount) エフェクト ON")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 右側: ペダルチェーン表示
            VStack(spacing: 4) {
                Text("🎸")
                    .font(.caption)

                ForEach(entry.pedalEmojis, id: \.self) { emoji in
                    Text("|")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(emoji)
                        .font(.title3)
                }

                Text("|")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("🔊")
                    .font(.caption)
            }
        }
        .padding(4)
    }

    // MARK: - Circular Widget

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "guitars.fill")
                    .font(.caption)
                Text("\(entry.enabledCount)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }

    // MARK: - Rectangular Widget

    private var rectangularWidget: some View {
        HStack(spacing: 8) {
            Image(systemName: "guitars.fill")
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.presetName ?? "カスタム")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text("\(entry.enabledCount)/\(entry.totalCount) エフェクト")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
