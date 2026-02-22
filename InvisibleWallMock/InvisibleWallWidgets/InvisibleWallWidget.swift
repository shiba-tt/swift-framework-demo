import WidgetKit
import SwiftUI

/// InvisibleWall セキュリティステータスウィジェット
struct InvisibleWallWidget: Widget {
    let kind = "InvisibleWallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InvisibleWallWidgetProvider()) { entry in
            InvisibleWallWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("InvisibleWall")
        .description("セキュリティゾーンの監視状態を確認します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct InvisibleWallWidgetEntry: TimelineEntry {
    let date: Date
    let isMonitoring: Bool
    let connectedDevices: Int
    let alertCount: Int
    let lastEvent: String?
    let lastEventTime: String?
}

struct InvisibleWallWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> InvisibleWallWidgetEntry {
        InvisibleWallWidgetEntry(
            date: Date(),
            isMonitoring: true,
            connectedDevices: 4,
            alertCount: 1,
            lastEvent: "ゾーン退出検知",
            lastEventTime: "5分前"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (InvisibleWallWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InvisibleWallWidgetEntry>) -> Void) {
        let entry = InvisibleWallWidgetEntry(
            date: Date(),
            isMonitoring: true,
            connectedDevices: 3,
            alertCount: 0,
            lastEvent: "全デバイス正常",
            lastEventTime: "1分前"
        )
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}

struct InvisibleWallWidgetEntryView: View {
    let entry: InvisibleWallWidgetEntry

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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundStyle(entry.isMonitoring ? .green : .gray)
                Text("InvisibleWall")
                    .font(.caption2)
                    .fontWeight(.bold)
            }

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(entry.isMonitoring ? .green : .gray)
                    .frame(width: 8, height: 8)
                Text(entry.isMonitoring ? "監視中" : "停止中")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 8))
                    Text("\(entry.connectedDevices)")
                        .font(.system(size: 10, weight: .bold))
                }

                if entry.alertCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.red)
                        Text("\(entry.alertCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.red)
                    }
                }
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(entry.isMonitoring ? .green : .gray)
                    Text("InvisibleWall")
                        .font(.caption)
                        .fontWeight(.bold)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(entry.isMonitoring ? .green : .gray)
                        .frame(width: 8, height: 8)
                    Text(entry.isMonitoring ? "監視中" : "停止中")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                HStack(spacing: 12) {
                    HStack(spacing: 2) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 10))
                        Text("\(entry.connectedDevices) 台")
                            .font(.caption)
                    }

                    if entry.alertCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                            Text("\(entry.alertCount) 件")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                if let event = entry.lastEvent {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最新イベント")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(event)
                            .font(.caption)
                            .fontWeight(.medium)
                        if let time = entry.lastEventTime {
                            Text(time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@main
struct InvisibleWallWidgetBundle: WidgetBundle {
    var body: some Widget {
        InvisibleWallWidget()
    }
}
