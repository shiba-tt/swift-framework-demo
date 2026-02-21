import SwiftUI
import SwiftData

/// ルーティン履歴画面
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RoutineRecord.date, order: .reverse)
    private var records: [RoutineRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    recordList
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
            description: Text("ルーティンを開始すると、ここに記録が表示されます")
        )
    }

    // MARK: - Record List

    private var recordList: some View {
        List {
            // 今週のサマリー
            weekSummarySection

            // 記録一覧
            ForEach(records, id: \.id) { record in
                RecordRow(record: record)
            }
        }
    }

    // MARK: - Week Summary

    private var weekSummarySection: some View {
        Section("今週のサマリー") {
            HStack {
                StatCard(
                    title: "完了率",
                    value: weeklyCompletionRate,
                    unit: "%",
                    systemImage: "checkmark.circle.fill",
                    color: .green
                )
                StatCard(
                    title: "ルーティン回数",
                    value: weeklyRecordCount,
                    unit: "回",
                    systemImage: "calendar",
                    color: .orange
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Computed

    private var weekRecords: [RoutineRecord] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return records.filter { $0.date >= startOfWeek }
    }

    private var weeklyRecordCount: Int {
        weekRecords.count
    }

    private var weeklyCompletionRate: Int {
        guard !weekRecords.isEmpty else { return 0 }
        let completed = weekRecords.filter(\.isFullyCompleted).count
        return Int(Double(completed) / Double(weekRecords.count) * 100)
    }
}

// MARK: - Record Row

private struct RecordRow: View {
    let record: RoutineRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date, style: .date)
                    .font(.subheadline.bold())

                HStack(spacing: 4) {
                    ForEach(RoutineStep.allCases) { step in
                        Image(systemName: step.systemImageName)
                            .font(.caption2)
                            .foregroundStyle(
                                record.completedSteps.contains(step.rawValue)
                                    ? .green
                                    : .gray.opacity(0.3)
                            )
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if record.isFullyCompleted {
                    Label("完了", systemImage: "checkmark.seal.fill")
                        .font(.caption2.bold())
                        .foregroundStyle(.green)
                } else {
                    Text("\(record.completedStepCount)/\(RoutineStep.totalCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let wakeUp = record.actualWakeUpTime {
                    Text(wakeUp, style: .time)
                        .font(.caption)
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
