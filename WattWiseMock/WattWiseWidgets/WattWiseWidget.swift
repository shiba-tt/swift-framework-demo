import SwiftUI
import WidgetKit

// MARK: - Timeline Provider

struct WattWiseTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WattWiseWidgetEntry {
        WattWiseWidgetEntry(
            date: Date(),
            familyName: "田中家",
            challengeTitle: "ピーク時間に電力 20% カット",
            challengeProgress: 0.72,
            co2Reduction: 2.1,
            costSaving: 1.80,
            cleanRate: 0.74
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WattWiseWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WattWiseWidgetEntry>) -> Void) {
        let data = loadWidgetData()
        let entry = WattWiseWidgetEntry(
            date: Date(),
            familyName: data?.familyName ?? "マイホーム",
            challengeTitle: data?.challengeTitle ?? "",
            challengeProgress: data?.challengeProgress ?? 0,
            co2Reduction: data?.co2Reduction ?? 0,
            costSaving: data?.costSaving ?? 0,
            cleanRate: data?.cleanRate ?? 0
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadWidgetData() -> WattWiseWidgetData? {
        let defaults = UserDefaults(suiteName: "group.com.example.wattwise")
        guard let data = defaults?.data(forKey: "widgetData") else { return nil }
        return try? JSONDecoder().decode(WattWiseWidgetData.self, from: data)
    }
}

// MARK: - Entry

struct WattWiseWidgetEntry: TimelineEntry {
    let date: Date
    let familyName: String
    let challengeTitle: String
    let challengeProgress: Double
    let co2Reduction: Double
    let costSaving: Double
    let cleanRate: Double
}

// MARK: - Small Widget

struct WattWiseSmallWidgetView: View {
    let entry: WattWiseWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.green)
                Text("WattWise")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }

            Text("🌱 クリーン率")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(Int(entry.cleanRate * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.green)

            Spacer()

            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text("🌍 CO2")
                        .font(.system(size: 8))
                    Text(String(format: "-%.1fkg", entry.co2Reduction))
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                VStack(alignment: .leading) {
                    Text("💰 節約")
                        .font(.system(size: 8))
                    Text(String(format: "$%.0f", entry.costSaving))
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Medium Widget

struct WattWiseMediumWidgetView: View {
    let entry: WattWiseWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Label("\(entry.familyName)", systemImage: "house.fill")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)

                Text("クリーン率 \(Int(entry.cleanRate * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    Label(String(format: "%.1fkg", entry.co2Reduction), systemImage: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Label(String(format: "$%.2f", entry.costSaving), systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("チャレンジ")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)

                Text(entry.challengeTitle)
                    .font(.caption2)
                    .lineLimit(2)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.2))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * entry.challengeProgress)
                    }
                }
                .frame(height: 8)

                Text("\(Int(entry.challengeProgress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget

struct WattWiseWidget: Widget {
    let kind = "WattWiseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WattWiseTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                WattWiseSmallWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("WattWise")
        .description("家族の節電チャレンジ進捗とクリーンエネルギー率を表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
