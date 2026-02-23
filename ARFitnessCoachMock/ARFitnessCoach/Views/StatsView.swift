import SwiftUI

// MARK: - StatsView

struct StatsView: View {
    var viewModel: ARFitnessCoachViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    overviewSection
                    weeklyChart
                    categoryBreakdown
                    formProgressSection
                }
                .padding()
            }
            .navigationTitle("統計")
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        HStack(spacing: 12) {
            OverviewCard(
                value: "\(viewModel.totalWorkouts)",
                label: "ワークアウト",
                systemImage: "figure.run",
                color: .green
            )
            OverviewCard(
                value: String(format: "%.0f", viewModel.totalCaloriesHistory),
                label: "合計 kcal",
                systemImage: "flame.fill",
                color: .orange
            )
            OverviewCard(
                value: String(format: "%.0f%%", viewModel.averageFormScore),
                label: "平均フォーム",
                systemImage: "chart.line.uptrend.xyaxis",
                color: .blue
            )
        }
    }

    // MARK: - Weekly Chart (Mock)

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間アクティビティ")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    let hasWorkout = viewModel.workoutHistory.contains { session in
                        Calendar.current.isDate(session.startDate, inSameDayAs: day)
                    }
                    let height: CGFloat = hasWorkout ? CGFloat.random(in: 40...120) : 10

                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hasWorkout ? Color.green : Color(.systemGray5))
                            .frame(width: 30, height: height)

                        Text(dayLabel(day))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150, alignment: .bottom)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var weekDays: [Date] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -6 + offset, to: Date())
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリー別")
                .font(.headline)

            ForEach(ExerciseCategory.allCases, id: \.self) { category in
                let count = viewModel.workoutHistory.filter { $0.exercise.category == category }.count
                if count > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: category.systemImage)
                            .foregroundStyle(category.color)
                            .frame(width: 30)

                        Text(category.rawValue)
                            .font(.subheadline)

                        Spacer()

                        Text("\(count)回")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        // プログレスバー
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray5))
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(category.color)
                                        .frame(width: geo.size.width * progressRatio(count: count))
                                }
                        }
                        .frame(width: 60, height: 6)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func progressRatio(count: Int) -> Double {
        guard viewModel.totalWorkouts > 0 else { return 0 }
        return Double(count) / Double(viewModel.totalWorkouts)
    }

    // MARK: - Form Progress Section

    private var formProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("フォームスコア推移")
                .font(.headline)

            if viewModel.workoutHistory.isEmpty {
                Text("トレーニングデータがありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                ForEach(viewModel.workoutHistory.prefix(5)) { session in
                    HStack(spacing: 12) {
                        Text(session.formGrade)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(session.formGradeColor)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.exercise.name)
                                .font(.subheadline)
                            Text(session.startDate, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(Int(session.averageFormScore))%")
                            .font(.headline)
                            .foregroundStyle(session.formGradeColor)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - OverviewCard

struct OverviewCard: View {
    let value: String
    let label: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - ResultSheet

struct ResultSheet: View {
    var viewModel: ARFitnessCoachViewModel
    let session: WorkoutSession

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    gradeSection
                    summarySection
                }
                .padding()
            }
            .navigationTitle("トレーニング完了")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.dismissResult()
                    }
                }
            }
        }
    }

    private var gradeSection: some View {
        VStack(spacing: 12) {
            Text(session.formGrade)
                .font(.system(size: 80))
                .fontWeight(.bold)
                .foregroundStyle(session.formGradeColor)

            Text("フォームスコア")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(Int(session.averageFormScore))%")
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(session.formGradeColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var summarySection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ResultCard(label: "エクササイズ", value: session.exercise.name, systemImage: session.exercise.category.systemImage, color: session.exercise.category.color)
            ResultCard(label: "完了レップ", value: "\(session.completedReps)回", systemImage: "repeat", color: .blue)
            ResultCard(label: "完了セット", value: "\(session.completedSets)セット", systemImage: "square.stack.3d.up.fill", color: .green)
            ResultCard(label: "消費カロリー", value: String(format: "%.0f kcal", session.caloriesBurned), systemImage: "flame.fill", color: .orange)
        }
    }
}

// MARK: - ResultCard

struct ResultCard: View {
    let label: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    StatsView(viewModel: ARFitnessCoachViewModel())
}
