import SwiftUI
import WidgetKit

/// メンタルヘルススコアウィジェット
struct MindMirrorScoreWidget: Widget {
    let kind = "MindMirrorScore"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScoreProvider()) { entry in
            ScoreWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("メンタルヘルススコア")
        .description("今日のメンタルヘルススコアとトレンドを表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Entry

struct ScoreEntry: TimelineEntry {
    let date: Date
    let overallScore: Int?
    let scoreLevel: String
    let trend: String
    let trendDirection: Int
    let topInsight: String?
}

// MARK: - Provider

struct ScoreProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScoreEntry {
        ScoreEntry(
            date: .now,
            overallScore: 72,
            scoreLevel: "良好",
            trend: "安定",
            trendDirection: 0,
            topInsight: "活動的な1日です"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ScoreEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScoreEntry>) -> Void) {
        let entry = ScoreEntry(
            date: .now,
            overallScore: nil,
            scoreLevel: "データなし",
            trend: "",
            trendDirection: 0,
            topInsight: nil
        )
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(1800)))
        completion(timeline)
    }
}

// MARK: - Widget View

struct ScoreWidgetView: View {
    let entry: ScoreEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .foregroundStyle(.purple)
                Text("MindMirror")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if let score = entry.overallScore {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.scoreLevel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 2) {
                            Image(systemName: entry.trendDirection > 0
                                  ? "arrow.up.right"
                                  : entry.trendDirection < 0
                                  ? "arrow.down.right"
                                  : "arrow.right")
                                .font(.caption2)
                            Text(entry.trend)
                                .font(.caption2)
                        }
                        .foregroundStyle(
                            entry.trendDirection > 0 ? .green
                            : entry.trendDirection < 0 ? .orange
                            : .blue
                        )
                    }
                }

                if let insight = entry.topInsight {
                    Text(insight)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            } else {
                Text("データ収集中")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("センサーデータが蓄積されるまでお待ちください")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
