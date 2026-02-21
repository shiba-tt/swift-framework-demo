import ActivityKit
import AlarmKit
import WidgetKit
import SwiftUI

/// MedicineGuard の Live Activity 定義
struct MedicineGuardLiveActivity: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MedicineGuardReminder",
            provider: MedicineGuardTimelineProvider()
        ) { entry in
            MedicineGuardWidgetView(entry: entry)
        }
        .configurationDisplayName("MedicineGuard 服薬リマインダー")
        .description("次の服薬予定と今日の服薬状況を表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Provider

struct MedicineGuardTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MedicineGuardWidgetEntry {
        MedicineGuardWidgetEntry(
            date: .now,
            nextMedicationName: "アムロジピン",
            nextDosage: "5mg",
            nextScheduleTime: "08:00",
            todayTaken: 2,
            todayTotal: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MedicineGuardWidgetEntry) -> Void) {
        let entry = MedicineGuardWidgetEntry(
            date: .now,
            nextMedicationName: "アムロジピン",
            nextDosage: "5mg",
            nextScheduleTime: "08:00",
            todayTaken: 2,
            todayTotal: 3
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MedicineGuardWidgetEntry>) -> Void) {
        let entry = MedicineGuardWidgetEntry(
            date: .now,
            nextMedicationName: nil,
            nextDosage: nil,
            nextScheduleTime: nil,
            todayTaken: 0,
            todayTotal: 0
        )
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60 * 15)))
        completion(timeline)
    }
}

// MARK: - Widget Entry

struct MedicineGuardWidgetEntry: TimelineEntry {
    let date: Date
    let nextMedicationName: String?
    let nextDosage: String?
    let nextScheduleTime: String?
    let todayTaken: Int
    let todayTotal: Int
}

// MARK: - Widget View

struct MedicineGuardWidgetView: View {
    let entry: MedicineGuardWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "pills.fill")
                    .foregroundStyle(.blue)
                Text("MedicineGuard")
                    .font(.caption.bold())
                Spacer()
            }

            Spacer()

            if let name = entry.nextMedicationName,
               let time = entry.nextScheduleTime {
                VStack(spacing: 4) {
                    Text("次の服薬")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(name)
                        .font(.subheadline.bold())
                    Text(time)
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            } else {
                Text("服薬予定なし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack {
                Text("\(entry.todayTaken)/\(entry.todayTotal)")
                    .font(.caption.bold())
                ProgressView(value: entry.todayTotal > 0 ? Double(entry.todayTaken) / Double(entry.todayTotal) : 0)
                    .tint(.blue)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
