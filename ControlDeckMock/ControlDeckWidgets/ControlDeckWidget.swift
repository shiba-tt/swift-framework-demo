import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct ControlDeckWidgetEntry: TimelineEntry {
    let date: Date
    let activeDevices: Int
    let totalDevices: Int
    let activeSceneName: String
    let roomSummaries: [RoomSummary]
}

struct RoomSummary: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let activeCount: Int
    let totalCount: Int
}

// MARK: - Timeline Provider

struct ControlDeckWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.example.controldeck"

    func placeholder(in context: Context) -> ControlDeckWidgetEntry {
        ControlDeckWidgetEntry(
            date: Date(),
            activeDevices: 6,
            totalDevices: 12,
            activeSceneName: "帰宅",
            roomSummaries: [
                RoomSummary(name: "リビング", icon: "sofa.fill", activeCount: 3, totalCount: 5),
                RoomSummary(name: "寝室", icon: "bed.double.fill", activeCount: 1, totalCount: 3),
                RoomSummary(name: "キッチン", icon: "fork.knife", activeCount: 1, totalCount: 1),
                RoomSummary(name: "玄関", icon: "door.left.hand.open", activeCount: 2, totalCount: 2)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ControlDeckWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ControlDeckWidgetEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: appGroupID)

        let roomNames = ["リビング", "寝室", "キッチン", "玄関", "ガレージ"]
        let roomIcons = ["sofa.fill", "bed.double.fill", "fork.knife", "door.left.hand.open", "car.fill"]
        var summaries: [RoomSummary] = []

        for (index, name) in roomNames.enumerated() {
            let summary = defaults?.string(forKey: "room_\(name)") ?? "0/0"
            let parts = summary.split(separator: "/")
            let active = Int(parts.first ?? "0") ?? 0
            let total = Int(parts.last ?? "0") ?? 0
            if total > 0 {
                summaries.append(RoomSummary(
                    name: name,
                    icon: roomIcons[index],
                    activeCount: active,
                    totalCount: total
                ))
            }
        }

        let entry = ControlDeckWidgetEntry(
            date: Date(),
            activeDevices: defaults?.integer(forKey: "activeDevices") ?? 0,
            totalDevices: defaults?.integer(forKey: "totalDevices") ?? 0,
            activeSceneName: defaults?.string(forKey: "activeScene") ?? "なし",
            roomSummaries: summaries
        )

        let nextUpdate = Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View

struct ControlDeckWidgetView: View {
    var entry: ControlDeckWidgetEntry
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundStyle(.cyan)
                Text("ControlDeck")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
            }

            Spacer()

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(entry.activeDevices)")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                Text("/ \(entry.totalDevices)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("デバイス稼働中")
                .font(.caption2)
                .foregroundStyle(.secondary)

            if entry.activeSceneName != "なし" {
                Label(entry.activeSceneName, systemImage: "sparkles")
                    .font(.caption2)
                    .foregroundStyle(.cyan)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 左: ステータス
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "house.fill")
                        .foregroundStyle(.cyan)
                    Text("ControlDeck")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.cyan)
                }

                Spacer()

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(entry.activeDevices)")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    Text("/ \(entry.totalDevices)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if entry.activeSceneName != "なし" {
                    Label(entry.activeSceneName, systemImage: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 右: 部屋サマリー
            VStack(alignment: .leading, spacing: 6) {
                ForEach(entry.roomSummaries.prefix(4)) { room in
                    HStack(spacing: 6) {
                        Image(systemName: room.icon)
                            .font(.caption2)
                            .frame(width: 16)
                        Text(room.name)
                            .font(.caption2)
                        Spacer()
                        Text("\(room.activeCount)/\(room.totalCount)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(4)
    }

    // MARK: - Large Widget

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: "house.fill")
                    .foregroundStyle(.cyan)
                Text("ControlDeck")
                    .font(.headline)
                    .foregroundStyle(.cyan)
                Spacer()
                Text("\(entry.activeDevices)/\(entry.totalDevices) 稼働中")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if entry.activeSceneName != "なし" {
                Label("シーン: \(entry.activeSceneName)", systemImage: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(.cyan)
            }

            Divider()

            // 部屋サマリー
            ForEach(entry.roomSummaries) { room in
                HStack(spacing: 10) {
                    Image(systemName: room.icon)
                        .font(.body)
                        .frame(width: 24)
                    Text(room.name)
                        .font(.subheadline)

                    Spacer()

                    // ミニバー
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.cyan)
                                .frame(
                                    width: room.totalCount > 0
                                        ? geometry.size.width * Double(room.activeCount) / Double(room.totalCount)
                                        : 0,
                                    height: 6
                                )
                        }
                    }
                    .frame(width: 60, height: 6)

                    Text("\(room.activeCount)/\(room.totalCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }

            Spacer()
        }
        .padding(4)
    }

    // MARK: - Circular Widget

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "house.fill")
                    .font(.body)
                Text("\(entry.activeDevices)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
    }

    // MARK: - Rectangular Widget

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "house.fill")
                Text("ControlDeck")
                    .fontWeight(.semibold)
            }
            .font(.caption)

            Text("\(entry.activeDevices)/\(entry.totalDevices) デバイス稼働中")
                .font(.caption2)

            if entry.activeSceneName != "なし" {
                Text("シーン: \(entry.activeSceneName)")
                    .font(.caption2)
            }
        }
    }

    // MARK: - Inline Widget

    private var inlineWidget: some View {
        Label("\(entry.activeDevices)台稼働中", systemImage: "house.fill")
    }
}

// MARK: - Widget Definition

struct ControlDeckWidget: Widget {
    let kind: String = "ControlDeckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ControlDeckWidgetProvider()) { entry in
            ControlDeckWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ControlDeck")
        .description("スマートホームの状態を一目で確認")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
