import SwiftUI
import SwiftData

/// 服薬履歴・アドヒアランスカレンダー画面
struct MedicationHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MedicationRecord.scheduledTime, order: .reverse)
    private var allRecords: [MedicationRecord]

    var body: some View {
        NavigationStack {
            Group {
                if allRecords.isEmpty {
                    emptyState
                } else {
                    historyContent
                }
            }
            .navigationTitle("履歴")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "まだ記録がありません",
            systemImage: "calendar.badge.clock",
            description: Text("服薬を記録すると、ここに履歴が表示されます")
        )
    }

    // MARK: - History Content

    private var historyContent: some View {
        List {
            // 週間サマリー
            weekSummarySection

            // アドヒアランスカレンダー
            adherenceCalendarSection

            // 詳細記録
            detailRecordsSection
        }
    }

    // MARK: - Week Summary

    private var weekSummarySection: some View {
        Section("今週のサマリー") {
            HStack {
                StatCard(
                    title: "服薬率",
                    value: weeklyAdherenceRate,
                    unit: "%",
                    systemImage: "chart.pie.fill",
                    color: .blue
                )
                StatCard(
                    title: "服薬回数",
                    value: weeklyTakenCount,
                    unit: "回",
                    systemImage: "checkmark.circle.fill",
                    color: .green
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Adherence Calendar

    private var adherenceCalendarSection: some View {
        Section("アドヒアランスカレンダー") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // 曜日ヘッダー
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // 直近28日のカレンダー
                ForEach(last28Days, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        adherenceRate: adherenceRate(for: date)
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Detail Records

    private var detailRecordsSection: some View {
        ForEach(groupedByDate, id: \.key) { date, records in
            Section {
                ForEach(records, id: \.id) { record in
                    RecordRow(record: record)
                }
            } header: {
                Text(date, style: .date)
            }
        }
    }

    // MARK: - Computed

    private var weekRecords: [MedicationRecord] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return allRecords.filter { $0.scheduledTime >= startOfWeek }
    }

    private var weeklyTakenCount: Int {
        weekRecords.filter(\.isTaken).count
    }

    private var weeklyAdherenceRate: Int {
        guard !weekRecords.isEmpty else { return 0 }
        let taken = weekRecords.filter(\.isTaken).count
        return Int(Double(taken) / Double(weekRecords.count) * 100)
    }

    private var last28Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        // 28日前の日曜日から開始
        let startDate = calendar.date(byAdding: .day, value: -27, to: today) ?? today
        let weekday = calendar.component(.weekday, from: startDate)
        let adjustedStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: startDate) ?? startDate

        return (0..<28).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: adjustedStart)
        }
    }

    private func adherenceRate(for date: Date) -> Double? {
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        let dayRecords = allRecords.filter { $0.scheduledTime >= date && $0.scheduledTime < nextDay }

        guard !dayRecords.isEmpty else { return nil }
        let taken = dayRecords.filter(\.isTaken).count
        return Double(taken) / Double(dayRecords.count)
    }

    private var groupedByDate: [(key: Date, value: [MedicationRecord])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allRecords) { record in
            calendar.startOfDay(for: record.scheduledTime)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

// MARK: - Calendar Day View

private struct CalendarDayView: View {
    let date: Date
    let adherenceRate: Double?

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption2)
                .foregroundStyle(isToday ? .blue : .primary)

            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
        }
        .frame(height: 30)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var dotColor: Color {
        guard let rate = adherenceRate else {
            return .clear
        }
        if rate >= 1.0 {
            return .green
        } else if rate > 0 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Record Row

private struct RecordRow: View {
    let record: MedicationRecord

    var body: some View {
        HStack {
            Image(systemName: record.isTaken ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(record.isTaken ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.medicationName)
                    .font(.subheadline.bold())

                HStack(spacing: 8) {
                    Text(record.dosage)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("予定: \(record.scheduledTime, style: .time)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if record.isTaken, let taken = record.takenAt {
                    Text(taken, style: .time)
                        .font(.caption)
                        .foregroundStyle(.green)

                    if let delay = record.delayMinutes, delay > 0 {
                        Text("+\(delay)分")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                } else {
                    Text("未服薬")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if record.snoozeCount > 0 {
                    Text("スヌーズ \(record.snoozeCount)回")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: Int
    let unit: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(value)")
                .font(.title.bold())
                .contentTransition(.numericText())

            Text("\(title)(\(unit))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
    }
}
