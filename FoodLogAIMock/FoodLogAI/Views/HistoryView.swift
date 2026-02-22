import SwiftUI

/// 食事履歴・週間レポート画面
struct HistoryView: View {
    let viewModel: FoodLogViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 週間カロリー推移
                    WeeklyCalorieChart(
                        history: viewModel.weeklyHistory,
                        target: viewModel.nutritionTarget.calorieTarget
                    )

                    // 週間平均
                    WeeklyAverageCard(
                        history: viewModel.weeklyHistory,
                        target: viewModel.nutritionTarget
                    )

                    // 日別詳細
                    DailyHistoryList(history: viewModel.weeklyHistory)
                }
                .padding()
            }
            .navigationTitle("履歴")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Weekly Calorie Chart

private struct WeeklyCalorieChart: View {
    let history: [DailyNutrition]
    let target: Int

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "E"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間カロリー推移")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(history.reversed()) { day in
                    let ratio = min(1.5, Double(day.totalCalories) / Double(target))
                    VStack(spacing: 4) {
                        Text("\(day.totalCalories)")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)

                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 120)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(barColor(ratio: ratio).opacity(0.7))
                                .frame(height: 120 * ratio / 1.5)
                        }

                        Text(dateFormatter.string(from: day.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)

            // 目標ライン表示
            HStack(spacing: 4) {
                Rectangle()
                    .fill(.orange)
                    .frame(width: 16, height: 2)
                Text("目標: \(target) kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func barColor(ratio: Double) -> Color {
        switch ratio {
        case ..<0.7: .blue
        case 0.7..<1.1: .green
        case 1.1..<1.3: .orange
        default: .red
        }
    }
}

// MARK: - Weekly Average Card

private struct WeeklyAverageCard: View {
    let history: [DailyNutrition]
    let target: NutritionTarget

    private var avgCalories: Int {
        guard !history.isEmpty else { return 0 }
        return history.reduce(0) { $0 + $1.totalCalories } / history.count
    }

    private var avgProtein: Double {
        guard !history.isEmpty else { return 0 }
        return history.reduce(0) { $0 + $1.totalProtein } / Double(history.count)
    }

    private var avgFat: Double {
        guard !history.isEmpty else { return 0 }
        return history.reduce(0) { $0 + $1.totalFat } / Double(history.count)
    }

    private var avgCarbs: Double {
        guard !history.isEmpty else { return 0 }
        return history.reduce(0) { $0 + $1.totalCarbs } / Double(history.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間平均")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                AverageStatCard(
                    label: "カロリー",
                    value: "\(avgCalories)",
                    unit: "kcal",
                    target: "\(target.calorieTarget)",
                    color: .orange
                )
                AverageStatCard(
                    label: "タンパク質",
                    value: String(format: "%.1f", avgProtein),
                    unit: "g",
                    target: String(format: "%.0f", target.proteinTarget),
                    color: .red
                )
                AverageStatCard(
                    label: "脂質",
                    value: String(format: "%.1f", avgFat),
                    unit: "g",
                    target: String(format: "%.0f", target.fatTarget),
                    color: .yellow
                )
                AverageStatCard(
                    label: "炭水化物",
                    value: String(format: "%.1f", avgCarbs),
                    unit: "g",
                    target: String(format: "%.0f", target.carbsTarget),
                    color: .blue
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct AverageStatCard: View {
    let label: String
    let value: String
    let unit: String
    let target: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("目標: \(target) \(unit)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Daily History List

private struct DailyHistoryList: View {
    let history: [DailyNutrition]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M月d日 (E)"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別記録")
                .font(.headline)

            ForEach(history) { day in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(dateFormatter.string(from: day.date))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(day.totalCalories) kcal")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }

                    HStack(spacing: 12) {
                        ForEach(MealType.allCases) { type in
                            let cal = day.calories(for: type)
                            if cal > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: type.systemImageName)
                                        .font(.caption2)
                                        .foregroundStyle(Color(type.colorName))
                                    Text("\(cal)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    // PFC ミニバー
                    let total = day.totalProtein * 4 + day.totalFat * 9 + day.totalCarbs * 4
                    if total > 0 {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Rectangle().fill(.red.opacity(0.6))
                                    .frame(width: geometry.size.width * (day.totalProtein * 4 / total))
                                Rectangle().fill(.yellow.opacity(0.6))
                                    .frame(width: geometry.size.width * (day.totalFat * 9 / total))
                                Rectangle().fill(.blue.opacity(0.6))
                                    .frame(width: geometry.size.width * (day.totalCarbs * 4 / total))
                            }
                        }
                        .frame(height: 6)
                        .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 4)

                if day.id != history.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
