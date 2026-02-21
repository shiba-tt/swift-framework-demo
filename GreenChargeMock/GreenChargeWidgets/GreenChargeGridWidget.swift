import SwiftUI
import WidgetKit

/// グリッド状態ウィジェット
struct GreenChargeGridWidget: Widget {
    let kind = "GreenChargeGrid"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GridWidgetProvider()) { entry in
            GridWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("グリッド状態")
        .description("現在の電力グリッドのクリーン度と次の充電推奨時間を表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Entry

struct GridWidgetEntry: TimelineEntry {
    let date: Date
    let cleanPercent: Int?
    let guidanceLevel: String
    let nextCleanWindowTime: String?
    let totalPoints: Int
}

// MARK: - Provider

struct GridWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> GridWidgetEntry {
        GridWidgetEntry(
            date: .now,
            cleanPercent: 78,
            guidanceLevel: "推奨",
            nextCleanWindowTime: "18:00〜22:00",
            totalPoints: 2450
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GridWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GridWidgetEntry>) -> Void) {
        let entry = GridWidgetEntry(
            date: .now,
            cleanPercent: nil,
            guidanceLevel: "--",
            nextCleanWindowTime: nil,
            totalPoints: 0
        )
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(900)))
        completion(timeline)
    }
}

// MARK: - Widget View

struct GridWidgetView: View {
    let entry: GridWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.green)
                Text("GreenCharge")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if let percent = entry.cleanPercent {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(percent)%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("クリーン")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(entry.guidanceLevel)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.green.opacity(0.12))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())

                if let windowTime = entry.nextCleanWindowTime {
                    Label("次: \(windowTime)", systemImage: "leaf.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("データなし")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
