import SwiftUI

struct HabitListView: View {
    @Bindable var viewModel: HabitCoachViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.habitsByCategory, id: \.category) { group in
                    Section {
                        ForEach(group.habits) { habit in
                            habitDetailRow(habit)
                        }
                    } header: {
                        Label(group.category.rawValue, systemImage: group.category.systemImageName)
                    }
                }

                Section("Siri & ショートカット") {
                    siriIntegrationInfo
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("習慣一覧")
        }
    }

    // MARK: - Habit Detail Row

    private func habitDetailRow(_ habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(habit.category.emoji)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.subheadline.bold())
                    Text("目標: \(habit.targetCount) \(habit.unit) / 日")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if viewModel.isCompleted(habit) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            }

            // 週間ストリーク表示
            if let streak = viewModel.streak(for: habit) {
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { day in
                        let completed = streak.completedDaysThisWeek[day]
                        Circle()
                            .fill(completed ? habit.category.color : .gray.opacity(0.2))
                            .frame(width: 10, height: 10)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(streak.currentStreak)日")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Siri フレーズ
            HStack(spacing: 4) {
                Image(systemName: "mic.fill")
                    .font(.caption2)
                    .foregroundStyle(.indigo)
                Text("\"\(habit.intentPhrase)\"")
                    .font(.caption)
                    .foregroundStyle(.indigo)
                    .italic()
            }

            if let time = habit.reminderTimeText {
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Siri Integration Info

    private var siriIntegrationInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            integrationRow(
                icon: "mic.circle.fill",
                color: .indigo,
                title: "Siri で記録",
                description: "「Hey Siri、HabitCoach で水を飲んだ」で習慣を記録"
            )
            integrationRow(
                icon: "sparkles",
                color: .purple,
                title: "コンテキスト学習",
                description: "iOS が使用パターンを学習し、最適なタイミングで提案"
            )
            integrationRow(
                icon: "rectangle.on.rectangle",
                color: .blue,
                title: "ウィジェット",
                description: "ロック画面から習慣の達成状況を確認・記録"
            )
            integrationRow(
                icon: "gearshape.fill",
                color: .gray,
                title: "Control Center",
                description: "コントロールセンターからワンタップで記録"
            )
            integrationRow(
                icon: "button.programmable",
                color: .orange,
                title: "Action Button",
                description: "物理ボタン一押しで最もよく使う習慣を記録"
            )
        }
    }

    private func integrationRow(
        icon: String, color: Color, title: String, description: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HabitListView(viewModel: HabitCoachViewModel())
}
