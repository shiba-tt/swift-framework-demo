import WidgetKit
import SwiftUI

/// BumpShare 共有クイックアクションウィジェット
struct BumpShareWidget: Widget {
    let kind = "BumpShareWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BumpShareWidgetProvider()) { entry in
            BumpShareWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("BumpShare")
        .description("最近の共有状況と近くのデバイスを確認します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BumpShareWidgetEntry: TimelineEntry {
    let date: Date
    let recentShareCount: Int
    let lastSharePeer: String?
    let lastShareContent: String?
    let nearbyDeviceCount: Int
}

struct BumpShareWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BumpShareWidgetEntry {
        BumpShareWidgetEntry(
            date: Date(),
            recentShareCount: 5,
            lastSharePeer: "iPhone (Taro)",
            lastShareContent: "連絡先",
            nearbyDeviceCount: 2
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BumpShareWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BumpShareWidgetEntry>) -> Void) {
        let entry = BumpShareWidgetEntry(
            date: Date(),
            recentShareCount: 3,
            lastSharePeer: "iPhone (Hanako)",
            lastShareContent: "Wi-Fi パスワード",
            nearbyDeviceCount: 1
        )
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(1800)))
        completion(timeline)
    }
}

struct BumpShareWidgetEntryView: View {
    let entry: BumpShareWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wave.3.right")
                    .foregroundStyle(.cyan)
                Text("BumpShare")
                    .font(.caption2)
                    .fontWeight(.bold)
            }

            Spacer()

            Text("\(entry.recentShareCount)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan)

            Text("今日の共有")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 8))
                Text("\(entry.nearbyDeviceCount) 台検出")
                    .font(.system(size: 9))
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // 左：統計
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "wave.3.right")
                        .foregroundStyle(.cyan)
                    Text("BumpShare")
                        .font(.caption)
                        .fontWeight(.bold)
                }

                Text("\(entry.recentShareCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)

                Text("今日の共有")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // 右：最近の共有
            VStack(alignment: .leading, spacing: 8) {
                if let peer = entry.lastSharePeer, let content = entry.lastShareContent {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最近の共有")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(content)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("→ \(peer)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 9))
                        .foregroundStyle(.cyan)
                    Text("\(entry.nearbyDeviceCount) 台のデバイスを検出中")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@main
struct BumpShareWidgetBundle: WidgetBundle {
    var body: some Widget {
        BumpShareWidget()
    }
}
