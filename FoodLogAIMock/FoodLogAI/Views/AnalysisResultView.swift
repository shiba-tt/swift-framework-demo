import SwiftUI

/// AI 分析結果表示画面
struct AnalysisResultView: View {
    let analysis: FoodAnalysisResult
    @Binding var selectedMealType: MealType
    let onRecord: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 検出結果サマリー
                    DetectionSummary(analysis: analysis)

                    // 料理リスト
                    DishList(dishes: analysis.dishes)

                    // 栄養サマリー
                    NutritionSummary(analysis: analysis)

                    // AI アドバイス
                    AIAdviceCard(advice: analysis.healthAdvice)

                    // 食事タイプ選択
                    VStack(alignment: .leading, spacing: 8) {
                        Text("食事タイプ")
                            .font(.headline)
                        Picker("食事タイプ", selection: $selectedMealType) {
                            ForEach(MealType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                    // 記録ボタン
                    Button(action: onRecord) {
                        Label("この食事を記録する", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .padding()
            }
            .navigationTitle("分析結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Detection Summary

private struct DetectionSummary: View {
    let analysis: FoodAnalysisResult

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                Text("AI が \(analysis.dishes.count) 品を検出")
                    .font(.headline)
                Spacer()
                Text("確信度: \(Int(analysis.averageConfidence * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                NutrientBadge(label: "カロリー", value: "\(analysis.totalCalories)", unit: "kcal", color: .orange)
                NutrientBadge(label: "P", value: String(format: "%.1f", analysis.totalProtein), unit: "g", color: .red)
                NutrientBadge(label: "F", value: String(format: "%.1f", analysis.totalFat), unit: "g", color: .yellow)
                NutrientBadge(label: "C", value: String(format: "%.1f", analysis.totalCarbs), unit: "g", color: .blue)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct NutrientBadge: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            Text(unit)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Dish List

private struct DishList: View {
    let dishes: [Dish]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("検出された料理")
                .font(.headline)

            ForEach(dishes) { dish in
                HStack {
                    Text(dish.category.emoji)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dish.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        HStack(spacing: 8) {
                            Text("P:\(String(format: "%.1f", dish.protein))g")
                            Text("F:\(String(format: "%.1f", dish.fat))g")
                            Text("C:\(String(format: "%.1f", dish.carbs))g")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(dish.calories) kcal")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        Text("\(Int(dish.confidence * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)

                if dish.id != dishes.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Nutrition Summary

private struct NutritionSummary: View {
    let analysis: FoodAnalysisResult

    private var totalCalorieEnergy: Double {
        analysis.totalProtein * 4 + analysis.totalFat * 9 + analysis.totalCarbs * 4
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("栄養バランス")
                .font(.headline)

            if totalCalorieEnergy > 0 {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        let pWidth = (analysis.totalProtein * 4 / totalCalorieEnergy) * geometry.size.width
                        let fWidth = (analysis.totalFat * 9 / totalCalorieEnergy) * geometry.size.width
                        let cWidth = (analysis.totalCarbs * 4 / totalCalorieEnergy) * geometry.size.width

                        RoundedRectangle(cornerRadius: 4)
                            .fill(.red.opacity(0.7))
                            .frame(width: pWidth)
                        RoundedRectangle(cornerRadius: 0)
                            .fill(.yellow.opacity(0.7))
                            .frame(width: fWidth)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.blue.opacity(0.7))
                            .frame(width: cWidth)
                    }
                }
                .frame(height: 16)
                .clipShape(Capsule())

                HStack {
                    PFCLabel(name: "タンパク質", percent: analysis.totalProtein * 4 / totalCalorieEnergy, color: .red)
                    Spacer()
                    PFCLabel(name: "脂質", percent: analysis.totalFat * 9 / totalCalorieEnergy, color: .yellow)
                    Spacer()
                    PFCLabel(name: "炭水化物", percent: analysis.totalCarbs * 4 / totalCalorieEnergy, color: .blue)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct PFCLabel: View {
    let name: String
    let percent: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: 8, height: 8)
            Text("\(name) \(Int(percent * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - AI Advice Card

private struct AIAdviceCard: View {
    let advice: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "brain.head.profile.fill")
                .font(.title2)
                .foregroundStyle(.purple)
            VStack(alignment: .leading, spacing: 4) {
                Text("AI アドバイス")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(advice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
