import SwiftUI

/// 食事撮影・分析画面
struct CaptureView: View {
    @Bindable var viewModel: FoodLogViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // カメラプレビュー（モック）
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))

                    if viewModel.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("AI が料理を分析中...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("食事を撮影してください")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 350)
                .padding(.horizontal)

                // 食事タイプ選択
                MealTypePicker(selected: $viewModel.selectedMealType)

                // 撮影ボタン
                HStack(spacing: 32) {
                    // OCR ボタン
                    Button {
                        Task { await scanNutritionLabel() }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.title2)
                            Text("栄養表示")
                                .font(.caption2)
                        }
                        .frame(width: 60, height: 60)
                    }
                    .tint(.blue)
                    .disabled(viewModel.isAnalyzing)

                    // メイン撮影ボタン
                    Button {
                        Task { await viewModel.analyzePhoto() }
                    } label: {
                        Circle()
                            .fill(.orange)
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                    }
                    .disabled(viewModel.isAnalyzing)

                    // ライブラリボタン
                    Button {
                        Task { await viewModel.analyzePhoto() }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("ライブラリ")
                                .font(.caption2)
                        }
                        .frame(width: 60, height: 60)
                    }
                    .tint(.secondary)
                    .disabled(viewModel.isAnalyzing)
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("撮影")
            .background(Color(.systemGroupedBackground))
        }
    }

    private func scanNutritionLabel() async {
        let manager = FoodClassificationManager.shared
        if let result = await manager.recognizeNutritionLabel() {
            let dish = Dish(
                name: result.productName,
                category: .other,
                calories: result.calories,
                protein: result.protein,
                fat: result.fat,
                carbs: result.carbs,
                confidence: result.confidence
            )
            let analysis = FoodAnalysisResult(
                dishes: [dish],
                healthAdvice: "栄養表示から正確な栄養データを読み取りました。",
                analysisDate: Date()
            )
            viewModel.recordMeal(from: analysis, mealType: viewModel.selectedMealType)
        }
    }
}

// MARK: - Meal Type Picker

private struct MealTypePicker: View {
    @Binding var selected: MealType

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MealType.allCases) { type in
                Button {
                    selected = type
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: type.systemImageName)
                            .font(.title3)
                        Text(type.rawValue)
                            .font(.caption2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        selected == type
                            ? Color(type.colorName).opacity(0.2)
                            : Color(.systemGray6)
                    )
                    .foregroundStyle(
                        selected == type
                            ? Color(type.colorName)
                            : .secondary
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
