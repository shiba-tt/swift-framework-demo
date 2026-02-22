import WidgetKit
import SwiftUI

struct ProximityPartyEntry: TimelineEntry {
    let date: Date
    let lastGameMode: String
    let topScore: Int
    let gamesPlayed: Int
}

struct ProximityPartyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProximityPartyEntry {
        ProximityPartyEntry(date: .now, lastGameMode: "空間鬼ごっこ", topScore: 120, gamesPlayed: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (ProximityPartyEntry) -> Void) {
        completion(ProximityPartyEntry(date: .now, lastGameMode: "空間鬼ごっこ", topScore: 120, gamesPlayed: 5))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProximityPartyEntry>) -> Void) {
        let entry = ProximityPartyEntry(
            date: .now,
            lastGameMode: ["空間鬼ごっこ", "宝探し", "距離当てクイズ"].randomElement() ?? "空間鬼ごっこ",
            topScore: Int.random(in: 50...200),
            gamesPlayed: Int.random(in: 1...20)
        )
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct ProximityPartyWidgetView: View {
    let entry: ProximityPartyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(.blue)
                Text("ProximityParty")
                    .font(.caption.bold())
                Spacer()
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("\(entry.topScore)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("ハイスコア")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(entry.gamesPlayed)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    Text("プレイ回数")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct ProximityPartyWidgetBundle: Widget {
    let kind = "ProximityPartyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProximityPartyWidgetProvider()) { entry in
            ProximityPartyWidgetView(entry: entry)
        }
        .configurationDisplayName("ProximityParty")
        .description("最新のゲーム結果とスコアを表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
