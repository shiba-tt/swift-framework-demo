import SwiftUI
import SwiftData
import Charts

/// 睡眠履歴画面
struct SleepHistoryView: View {
    @Query(sort: \SleepRecord.date, order: .reverse)
    private var records: [SleepRecord]

    var body: some View {
        NavigationStack {
            List {
                if !records.isEmpty {
                    // 睡眠スコアチャート
                    Section("睡眠スコア推移") {
                        scoreChart
                    }

                    // 統計サマリー
                    Section("今週のサマリー") {
                        summarySection
                    }
                }

                // 履歴リスト
                Section("履歴") {
                    if records.isEmpty {
                        ContentUnavailableView(
                            "まだ記録がありません",
                            systemImage: "moon.zzz",
                            description: Text("アラームを使って起床すると睡眠記録が保存されます")
                        )
                    } else {
                        ForEach(records) { record in
                            recordRow(record)
                        }
                    }
                }
            }
            .navigationTitle("睡眠履歴")
        }
    }

    // MARK: - Components

    private var scoreChart: some View {
        Chart(records.prefix(14).reversed()) { record in
            LineMark(
                x: .value("日付", record.date, unit: .day),
                y: .value("スコア", record.sleepScore)
            )
            .foregroundStyle(.indigo)

            PointMark(
                x: .value("日付", record.date, unit: .day),
                y: .value("スコア", record.sleepScore)
            )
            .foregroundStyle(record.wokeUpSmart ? .cyan : .orange)
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: [0, 25, 50, 75, 100])
        }
        .frame(height: 180)
    }

    private var summarySection: some View {
        let weekRecords = records.filter {
            $0.date > Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        }

        return Group {
            LabeledContent("平均スコア") {
                let avg = weekRecords.isEmpty ? 0 : weekRecords.map(\.sleepScore).reduce(0, +) / weekRecords.count
                Text("\(avg)/100")
                    .fontWeight(.medium)
            }

            LabeledContent("平均睡眠時間") {
                let avg = weekRecords.isEmpty ? 0.0 : weekRecords.map(\.sleepDurationHours).reduce(0, +) / Double(weekRecords.count)
                Text(String(format: "%.1f時間", avg))
                    .fontWeight(.medium)
            }

            LabeledContent("スマート起床率") {
                let smartCount = weekRecords.filter(\.wokeUpSmart).count
                let rate = weekRecords.isEmpty ? 0 : smartCount * 100 / weekRecords.count
                Text("\(rate)%")
                    .fontWeight(.medium)
            }
        }
    }

    private func recordRow(_ record: SleepRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.date, format: .dateTime.month().day().weekday(.abbreviated))
                    .font(.headline)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: record.wokeUpSmart ? "brain.head.profile.fill" : "alarm.fill")
                        .foregroundStyle(record.wokeUpSmart ? .cyan : .orange)
                    Text("スコア \(record.sleepScore)")
                        .fontWeight(.medium)
                }
            }

            HStack(spacing: 16) {
                Label(String(format: "%.1f時間", record.sleepDurationHours), systemImage: "bed.double")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if record.wokeUpSmart && record.minutesSavedBySmart > 0 {
                    Label("\(record.minutesSavedBySmart)分早起き", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                }

                Label(record.wakeUpTime, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
