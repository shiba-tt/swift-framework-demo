import SwiftUI

/// ケアスケジュール一覧画面
struct CareScheduleView: View {
    @Bindable var viewModel: PlantDoctorViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !viewModel.overdueSchedules.isEmpty {
                        overdueSection
                    }
                    todaySection
                    upcomingSection
                }
                .padding()
            }
            .navigationTitle("ケアスケジュール")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Overdue Section

    private var overdueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("期限超過")
                    .font(.headline)
                    .foregroundStyle(.red)
            }

            ForEach(viewModel.overdueSchedules) { schedule in
                scheduleRow(schedule, isOverdue: true)
            }
        }
        .padding()
        .background(Color.red.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.green)
                Text("今日のケア")
                    .font(.headline)
                Spacer()
                Text(todayDateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.todaySchedules.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("今日のケアはすべて完了です")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(viewModel.todaySchedules) { schedule in
                    scheduleRow(schedule, isOverdue: false)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Upcoming Section

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今後の予定")
                .font(.headline)

            let upcoming = viewModel.careSchedules
                .filter { !$0.isCompleted && !$0.isOverdue && !viewModel.todaySchedules.contains(where: { t in t.id == $0.id }) }
                .sorted { $0.scheduledDate < $1.scheduledDate }
                .prefix(10)

            if upcoming.isEmpty {
                Text("予定はありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(Array(upcoming)) { schedule in
                    scheduleRow(schedule, isOverdue: false)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Schedule Row

    private func scheduleRow(_ schedule: CareSchedule, isOverdue: Bool) -> some View {
        HStack(spacing: 12) {
            // 植物の絵文字
            Text(schedule.plantEmoji)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(isOverdue ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // ケア情報
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(schedule.careType.emoji)
                    Text(schedule.careType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Text(schedule.plantName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 日付 & 完了ボタン
            VStack(alignment: .trailing, spacing: 4) {
                Text(schedule.daysUntilText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isOverdue ? .red : .primary)

                Button {
                    viewModel.completeSchedule(schedule)
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private var todayDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: Date())
    }
}

#Preview {
    CareScheduleView(viewModel: PlantDoctorViewModel())
}
