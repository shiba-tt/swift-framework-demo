import SwiftUI

/// 今日の食事ダッシュボード画面
struct DashboardView: View {
    let viewModel: FoodLogViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // カロリーリング
                    CalorieRingCard(
                        calories: viewModel.todayCalories,
                        target: viewModel.nutritionTarget.calorieTarget,
                        progress: viewModel.calorieProgress
                    )

                    // PFC バランス
                    PFCCard(
                        protein: viewModel.todayProtein,
                        fat: viewModel.todayFat,
                        carbs: viewModel.todayCarbs,
                        target: viewModel.nutritionTarget
                    )

                    // 食事リスト
                    MealListSection(
                        meals: viewModel.todayMeals,
                        onDelete: { viewModel.removeMeal($0) }
                    )

                    // アドバイス
                    AdviceCard(advice: viewModel.healthAdvice)
                }
                .padding()
            }
            .navigationTitle("FoodLog AI")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Calorie Ring Card

private struct CalorieRingCard: View {
    let calories: Int
    let target: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: min(1.0, progress))
                    .stroke(
                        progress > 1.0 ? Color.red : Color.orange,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(calories)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 8) {
                Text("今日の摂取カロリー")
                    .font(.headline)

                HStack {
                    Text("目標")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(target) kcal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("残り")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    let remaining = max(0, target - calories)
                    Text("\(remaining) kcal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(remaining > 0 ? .green : .red)
                }
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - PFC Card

private struct PFCCard: View {
    let protein: Double
    let fat: Double
    let carbs: Double
    let target: NutritionTarget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PFC バランス")
                .font(.headline)

            HStack(spacing: 16) {
                NutrientBar(
                    label: "P",
                    name: "タンパク質",
                    value: protein,
                    target: target.proteinTarget,
                    color: .red
                )
                NutrientBar(
                    label: "F",
                    name: "脂質",
                    value: fat,
                    target: target.fatTarget,
                    color: .yellow
                )
                NutrientBar(
                    label: "C",
                    name: "炭水化物",
                    value: carbs,
                    target: target.carbsTarget,
                    color: .blue
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct NutrientBar: View {
    let label: String
    let name: String
    let value: Double
    let target: Double
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(1.0, value / target)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 24, height: 80)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.7))
                    .frame(width: 24, height: 80 * progress)
            }

            Text(String(format: "%.1fg", value))
                .font(.caption)
                .fontWeight(.medium)
            Text(name)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Meal List Section

private struct MealListSection: View {
    let meals: [Meal]
    let onDelete: (Meal) -> Void

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("食事記録")
                .font(.headline)

            if meals.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("食事を撮影して記録しましょう")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                ForEach(meals) { meal in
                    MealRow(meal: meal, timeFormatter: timeFormatter)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onDelete(meal)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct MealRow: View {
    let meal: Meal
    let timeFormatter: DateFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: meal.mealType.systemImageName)
                    .foregroundStyle(Color(meal.mealType.colorName))
                Text(meal.mealType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(timeFormatter.string(from: meal.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(meal.totalCalories) kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
            }

            ForEach(meal.dishes) { dish in
                HStack {
                    Text(dish.category.emoji)
                        .font(.caption)
                    Text(dish.name)
                        .font(.caption)
                    Spacer()
                    Text("\(dish.calories) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 28)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Advice Card

private struct AdviceCard: View {
    let advice: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.orange)
            Text(advice)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
