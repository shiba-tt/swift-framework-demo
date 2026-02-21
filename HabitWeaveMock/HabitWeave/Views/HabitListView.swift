import SwiftUI

/// 習慣一覧と管理画面
struct HabitListView: View {
    @Bindable var viewModel: HabitWeaveViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    activeHabitsSection
                    if !viewModel.inactiveHabits.isEmpty {
                        inactiveHabitsSection
                    }
                }
                .padding()
            }
            .navigationTitle("習慣")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Active Habits

    private var activeHabitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("アクティブ")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.activeHabits.count)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.activeHabits) { habit in
                habitCard(habit)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Inactive Habits

    private var inactiveHabitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("休止中")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.inactiveHabits.count)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.inactiveHabits) { habit in
                habitCard(habit)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Habit Card

    private func habitCard(_ habit: Habit) -> some View {
        let isCompleted = viewModel.isCompletedToday(habit)
        let weeklyCount = viewModel.weeklyCompletionCount(for: habit)

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                // カテゴリアイコン
                ZStack {
                    Circle()
                        .fill(habitColor(habit.color).opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text(habit.category.emoji)
                        .font(.title3)
                }

                // 習慣情報
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    HStack(spacing: 8) {
                        Label(habit.durationText, systemImage: "clock")
                        Text("·")
                        Text(habit.frequencyText)
                        Text("·")
                        HStack(spacing: 2) {
                            Text(habit.preferredTimeSlot.emoji)
                            Text(habit.preferredTimeSlot.rawValue)
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // 完了チェック
                if habit.isActive {
                    Button {
                        viewModel.toggleCompletion(for: habit)
                    } label: {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            // 週間進捗バー
            if habit.isActive {
                HStack(spacing: 4) {
                    Text("今週")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    ForEach(0..<habit.frequency.timesPerWeek, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < weeklyCount ? habitColor(habit.color) : Color(.systemGray5))
                            .frame(height: 6)
                    }

                    Text("\(weeklyCount)/\(habit.frequency.timesPerWeek)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // アクションボタン
            HStack {
                Button {
                    viewModel.toggleActive(for: habit)
                } label: {
                    Label(
                        habit.isActive ? "休止する" : "再開する",
                        systemImage: habit.isActive ? "pause.circle" : "play.circle"
                    )
                    .font(.caption)
                    .foregroundStyle(habit.isActive ? .orange : .green)
                }
                .buttonStyle(.plain)

                Spacer()

                Label(habit.category.rawValue, systemImage: habit.category.systemImageName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
    HabitListView(viewModel: HabitWeaveViewModel())
}
