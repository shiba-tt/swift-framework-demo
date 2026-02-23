import SwiftUI

struct TodayView: View {
    @Bindable var viewModel: HabitCoachViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overallProgressCard
                    if !viewModel.suggestions.isEmpty {
                        siriSuggestionsSection
                    }
                    habitsChecklist
                }
                .padding()
            }
            .navigationTitle("今日の習慣")
        }
    }

    // MARK: - Overall Progress

    private var overallProgressCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.15), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: viewModel.overallCompletionRatio)
                    .stroke(
                        AngularGradient(
                            colors: [.indigo, .purple, .indigo],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.5), value: viewModel.overallCompletionRatio)

                VStack(spacing: 2) {
                    Text("\(viewModel.totalCompletedToday)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("/ \(viewModel.totalHabitsCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(progressMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var progressMessage: String {
        let ratio = viewModel.overallCompletionRatio
        if ratio >= 1.0 {
            return "全ての習慣を完了しました！素晴らしい！"
        } else if ratio >= 0.7 {
            return "あと少し！今日も良い調子です。"
        } else if ratio >= 0.3 {
            return "良いペースです。コツコツ続けましょう。"
        } else {
            return "今日も一歩ずつ。まずは一つ完了してみましょう。"
        }
    }

    // MARK: - Siri Suggestions

    private var siriSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.indigo)
                Text("Siri からの提案")
                    .font(.headline)
            }

            ForEach(viewModel.suggestions) { suggestion in
                suggestionCard(suggestion)
            }
        }
    }

    private func suggestionCard(_ suggestion: SiriSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.indigo)
                Text(suggestion.habitName)
                    .font(.subheadline.bold())
                Spacer()
                Button {
                    viewModel.dismissSuggestion(suggestion)
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(suggestion.message)
                .font(.subheadline)

            Text(suggestion.reason)
                .font(.caption)
                .foregroundStyle(.secondary)
                .italic()

            HStack {
                Button("完了記録") {
                    if let habit = viewModel.habits.first(where: { $0.name == suggestion.habitName }) {
                        viewModel.logHabit(habit)
                    }
                    viewModel.dismissSuggestion(suggestion)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .controlSize(.small)

                Button("後で") {
                    viewModel.dismissSuggestion(suggestion)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(.indigo.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Habits Checklist

    private var habitsChecklist: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("チェックリスト")
                .font(.headline)

            ForEach(viewModel.habits) { habit in
                habitRow(habit)
            }
        }
    }

    private func habitRow(_ habit: Habit) -> some View {
        let completed = viewModel.isCompleted(habit)
        let progress = viewModel.todayProgress(for: habit)
        let ratio = viewModel.completionRatio(for: habit)

        return HStack(spacing: 12) {
            Button {
                if !completed {
                    viewModel.logHabit(habit)
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(completed ? habit.category.color : .gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 36, height: 36)

                    Circle()
                        .trim(from: 0, to: ratio)
                        .stroke(habit.category.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))

                    if completed {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(habit.category.color)
                    } else {
                        Text(habit.category.emoji)
                            .font(.caption)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.name)
                        .font(.subheadline)
                        .strikethrough(completed)
                        .foregroundStyle(completed ? .secondary : .primary)

                    if let streak = viewModel.streak(for: habit), streak.currentStreak >= 3 {
                        Text("\(streak.currentStreak)日連続")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if habit.targetCount > 1 {
                    Text("\(progress) / \(habit.targetCount) \(habit.unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if !completed {
                Button {
                    viewModel.logHabit(habit)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(habit.category.color)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TodayView(viewModel: HabitCoachViewModel())
}
