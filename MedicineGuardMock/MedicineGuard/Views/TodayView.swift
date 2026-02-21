import SwiftUI

/// 今日の服薬状況画面
struct TodayView: View {
    @Bindable var viewModel: MedicationViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // アドヒアランスサマリー
                    adherenceSummary

                    // 連続服薬日数
                    streakCard

                    // 今日の服薬一覧
                    todayMedicationList

                    // 次の服薬
                    if let next = viewModel.nextScheduledMedication {
                        nextMedicationCard(next)
                    }
                }
                .padding()
            }
            .navigationTitle("MedicineGuard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Adherence Summary

    private var adherenceSummary: some View {
        VStack(spacing: 12) {
            // 円形進捗
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: Double(viewModel.todayAdherenceRate) / 100.0)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: viewModel.todayAdherenceRate)

                VStack(spacing: 4) {
                    Text("\(viewModel.todayAdherenceRate)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("今日の服薬率")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 160, height: 160)

            Text("\(viewModel.todayTakenCount) / \(viewModel.todayScheduledCount) 服薬済み")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("連続服薬")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.streakDays)日")
                    .font(.title2.bold())
            }

            Spacer()

            if viewModel.streakDays >= 7 {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .padding()
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Today Medication List

    private var todayMedicationList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の服薬")
                .font(.headline)

            if viewModel.todayRecords.isEmpty {
                Text("服薬予定はありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.todayRecords, id: \.id) { record in
                    TodayMedicationRow(record: record) {
                        viewModel.recordMedicationTaken(record.medicationID)
                    }
                }
            }
        }
    }

    // MARK: - Next Medication Card

    private func nextMedicationCard(_ medication: Medication) -> some View {
        HStack {
            Image(systemName: medication.category.systemImageName)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("次の服薬")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(medication.name) \(medication.dosage)")
                    .font(.subheadline.bold())
                Text(medication.scheduleTimeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "bell.fill")
                .foregroundStyle(.blue)
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Today Medication Row

private struct TodayMedicationRow: View {
    let record: MedicationRecord
    let onTake: () -> Void

    var body: some View {
        HStack {
            // 服薬状態アイコン
            Image(systemName: record.isTaken ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(record.isTaken ? .green : .gray)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.medicationName)
                    .font(.subheadline.bold())
                    .strikethrough(record.isTaken)

                HStack(spacing: 8) {
                    Text(record.dosage)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(record.scheduledTime, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if record.isTaken {
                if let taken = record.takenAt {
                    Text(taken, style: .time)
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                Button("服用済み") {
                    onTake()
                }
                .font(.caption.bold())
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
