import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct MeetingCostEntry: TimelineEntry {
    let date: Date
    let todayMeetingCount: Int
    let todayTotalMinutes: Int
    let todayCost: Double
    let deepWorkScore: Int
    let nextMeetingTitle: String?
}

// MARK: - Timeline Provider

struct MeetingCostProvider: TimelineProvider {
    func placeholder(in context: Context) -> MeetingCostEntry {
        MeetingCostEntry(
            date: .now,
            todayMeetingCount: 5,
            todayTotalMinutes: 180,
            todayCost: 75000,
            deepWorkScore: 45,
            nextMeetingTitle: "チーム定例ミーティング"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MeetingCostEntry) -> Void) {
        let entry = MeetingCostEntry(
            date: .now,
            todayMeetingCount: 3,
            todayTotalMinutes: 120,
            todayCost: 50000,
            deepWorkScore: 60,
            nextMeetingTitle: "プロジェクトレビュー"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MeetingCostEntry>) -> Void) {
        let entry = MeetingCostEntry(
            date: .now,
            todayMeetingCount: 0,
            todayTotalMinutes: 0,
            todayCost: 0,
            deepWorkScore: 100,
            nextMeetingTitle: nil
        )
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(1800))
        )
        completion(timeline)
    }
}

// MARK: - Widget View

struct MeetingCostWidgetView: View {
    var entry: MeetingCostEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        default:
            smallView
        }
    }

    // MARK: - Small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "yensign.circle.fill")
                    .foregroundStyle(.orange)
                Text("MeetingLens")
                    .font(.caption.bold())
            }

            Spacer()

            Text(costText)
                .font(.title2.bold())
                .foregroundStyle(.orange)

            HStack {
                Label("\(entry.todayMeetingCount)件", systemImage: "calendar")
                Spacer()
                Label("DW \(entry.deepWorkScore)", systemImage: "brain.head.profile.fill")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium

    private var mediumView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "yensign.circle.fill")
                        .foregroundStyle(.orange)
                    Text("MeetingLens")
                        .font(.caption.bold())
                }

                Spacer()

                Text("今日の会議コスト")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(costText)
                    .font(.title2.bold())
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Label("\(entry.todayMeetingCount)件の会議", systemImage: "calendar")
                Label("\(entry.todayTotalMinutes)分", systemImage: "clock")
                Label("DW \(entry.deepWorkScore)pt", systemImage: "brain.head.profile.fill")

                if let next = entry.nextMeetingTitle {
                    Divider()
                    Text("次: \(next)")
                        .font(.caption2)
                        .lineLimit(1)
                }

                Spacer()
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Circular

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "yensign.circle.fill")
                    .font(.caption)
                Text("\(entry.todayMeetingCount)")
                    .font(.title3.bold())
                Text("件")
                    .font(.system(size: 8))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Rectangular

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "yensign.circle.fill")
                Text("MeetingLens")
                    .font(.caption.bold())
            }
            Text("会議 \(entry.todayMeetingCount)件 | \(costText)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("DW \(entry.deepWorkScore)pt")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Helpers

    private var costText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: entry.todayCost)) ?? "¥0"
    }
}

// MARK: - Widget Definition

struct MeetingCostWidget: Widget {
    let kind: String = "MeetingCostWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MeetingCostProvider()) { entry in
            MeetingCostWidgetView(entry: entry)
        }
        .configurationDisplayName("会議コスト")
        .description("今日の会議コストとディープワークスコアを表示")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}
