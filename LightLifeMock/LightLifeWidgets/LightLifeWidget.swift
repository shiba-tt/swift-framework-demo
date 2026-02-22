import WidgetKit
import SwiftUI

struct LightLifeEntry: TimelineEntry {
    let date: Date
    let currentLux: Double
    let rhythmScore: Int
    let luxLevel: String
}

struct LightLifeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LightLifeEntry {
        LightLifeEntry(date: .now, currentLux: 350, rhythmScore: 78, luxLevel: "室内")
    }

    func getSnapshot(in context: Context, completion: @escaping (LightLifeEntry) -> Void) {
        completion(LightLifeEntry(date: .now, currentLux: 350, rhythmScore: 78, luxLevel: "室内"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LightLifeEntry>) -> Void) {
        let entry = LightLifeEntry(
            date: .now,
            currentLux: Double.random(in: 50...2000),
            rhythmScore: Int.random(in: 55...90),
            luxLevel: "室内"
        )
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(900)))
        completion(timeline)
    }
}

struct LightLifeWidgetView: View {
    let entry: LightLifeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.yellow)
                Text("LightLife")
                    .font(.caption.bold())
                Spacer()
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(entry.currentLux))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("lux")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(entry.rhythmScore)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)
                    Text("リズム")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct LightLifeWidgetBundle: Widget {
    let kind = "LightLifeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LightLifeWidgetProvider()) { entry in
            LightLifeWidgetView(entry: entry)
        }
        .configurationDisplayName("LightLife")
        .description("現在の光環境と概日リズムスコアを表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
