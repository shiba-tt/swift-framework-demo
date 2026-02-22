import SwiftUI
import WidgetKit

// MARK: - Timeline Provider

struct LifeRewindTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LifeRewindWidgetEntry {
        LifeRewindWidgetEntry(
            date: Date(),
            onThisDayTitle: "友人の結婚式",
            onThisDayYearsAgo: 2,
            totalEventsThisYear: 342,
            topCategoryEmoji: "💼",
            topCategoryName: "仕事"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeRewindWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeRewindWidgetEntry>) -> Void) {
        let data = loadWidgetData()
        let entry = LifeRewindWidgetEntry(
            date: Date(),
            onThisDayTitle: data?.onThisDayTitle,
            onThisDayYearsAgo: data?.onThisDayYearsAgo,
            totalEventsThisYear: data?.totalEventsThisYear ?? 0,
            topCategoryEmoji: data?.topCategoryEmoji ?? "📅",
            topCategoryName: data?.topCategoryName ?? "不明"
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadWidgetData() -> WidgetData? {
        let defaults = UserDefaults(suiteName: "group.com.example.liferewind")
        guard let data = defaults?.data(forKey: "widgetData") else { return nil }
        return try? JSONDecoder().decode(WidgetData.self, from: data)
    }
}

// MARK: - Entry

struct LifeRewindWidgetEntry: TimelineEntry {
    let date: Date
    let onThisDayTitle: String?
    let onThisDayYearsAgo: Int?
    let totalEventsThisYear: Int
    let topCategoryEmoji: String
    let topCategoryName: String
}

// MARK: - Widget Views

struct LifeRewindSmallWidgetView: View {
    let entry: LifeRewindWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.indigo)
                Text("On This Day")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.indigo)
            }

            if let title = entry.onThisDayTitle,
               let yearsAgo = entry.onThisDayYearsAgo {
                Text("\(yearsAgo)年前")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            } else {
                Text("過去のイベントはありません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack {
                Text(entry.topCategoryEmoji)
                Text("今年 \(entry.totalEventsThisYear) 件")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

struct LifeRewindMediumWidgetView: View {
    let entry: LifeRewindWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // On This Day
            VStack(alignment: .leading, spacing: 6) {
                Label("On This Day", systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.indigo)

                if let title = entry.onThisDayTitle,
                   let yearsAgo = entry.onThisDayYearsAgo {
                    Text("\(yearsAgo)年前の今日")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                } else {
                    Text("記録なし")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            // 年間サマリー
            VStack(alignment: .leading, spacing: 6) {
                Text("今年の記録")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.indigo)
                    Text("\(entry.totalEventsThisYear) 件")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 4) {
                    Text(entry.topCategoryEmoji)
                    Text(entry.topCategoryName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget

struct LifeRewindWidget: Widget {
    let kind = "LifeRewindWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeRewindTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                LifeRewindSmallWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("LifeRewind")
        .description("過去の同じ日のイベントと年間サマリーを表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
