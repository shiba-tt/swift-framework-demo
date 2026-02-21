import SwiftUI

/// 今日のスケジュールと習慣配置を表示する画面
struct TodayScheduleView: View {
    @Bindable var viewModel: HabitWeaveViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todaySummaryCard
                    freeTimeSlotsSection
                    timelineSection
                }
                .padding()
            }
            .navigationTitle("今日のスケジュール")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Today Summary

    private var todaySummaryCard: some View {
        HStack(spacing: 16) {
            // 完了率
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0, to: viewModel.todayCompletionRate)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    Text(viewModel.todayCompletionRateText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
                Text("達成率")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // 統計
            VStack(alignment: .leading, spacing: 8) {
                summaryRow(emoji: "✅", label: "完了", value: viewModel.todayProgressText)
                summaryRow(emoji: "🕐", label: "空き時間", value: viewModel.totalFreeTimeText)
                summaryRow(emoji: "🔥", label: "連続達成", value: "\(viewModel.currentStreak)日")
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryRow(emoji: String, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(emoji)
                .font(.caption)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .monospacedDigit()
        }
    }

    // MARK: - Free Time Slots

    private var freeTimeSlotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("空き時間")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.freeTimeSlots.count)スロット")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.freeTimeSlots.isEmpty {
                Text("今日の空き時間はありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                ForEach(viewModel.freeTimeSlots) { slot in
                    freeSlotRow(slot)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func freeSlotRow(_ slot: FreeTimeSlot) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.green.opacity(0.4))
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(slot.timeRangeText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(slot.durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // この時間帯に配置された習慣
            let habitsInSlot = viewModel.scheduledHabits.filter { $0.freeSlot.id == slot.id }
            if !habitsInSlot.isEmpty {
                HStack(spacing: 4) {
                    ForEach(habitsInSlot) { scheduled in
                        Text(scheduled.habit.category.emoji)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スケジュール配置")
                .font(.headline)

            if viewModel.scheduledHabits.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("習慣をカレンダーに配置中...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(viewModel.scheduledHabits) { scheduled in
                    scheduledHabitRow(scheduled)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func scheduledHabitRow(_ scheduled: ScheduledHabit) -> some View {
        let isCompleted = viewModel.isCompletedToday(scheduled.habit)

        return HStack(spacing: 12) {
            // 時刻
            VStack(spacing: 2) {
                Text(scheduled.startTimeText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
                Text(scheduled.endTimeText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .frame(width: 44)

            // カラーバー
            RoundedRectangle(cornerRadius: 2)
                .fill(habitColor(scheduled.habit.color))
                .frame(width: 4, height: 44)

            // 習慣情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(scheduled.habit.category.emoji)
                        .font(.caption)
                    Text(scheduled.habit.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Text(scheduled.habit.durationText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 完了ボタン
            Button {
                viewModel.toggleCompletion(for: scheduled.habit)
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func habitColor(_ color: HabitColor) -> Color {
        switch color {
        case .blue: .blue
        case .green: .green
        case .orange: .orange
        case .purple: .purple
        case .pink: .pink
        case .red: .red
        }
    }
}

#Preview {
    TodayScheduleView(viewModel: HabitWeaveViewModel())
}
