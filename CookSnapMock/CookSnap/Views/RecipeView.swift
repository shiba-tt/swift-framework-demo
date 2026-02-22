import SwiftUI

struct RecipeView: View {
    @Bindable var viewModel: CookSnapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let entry = viewModel.currentRecipe {
                        recipeCard(entry)
                        stepsSection(entry)
                        ingredientsUsedSection(entry)
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("レシピ")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("まだレシピがありません")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("「スキャン」タブで食材を撮影し、\nレシピを生成してみましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    // MARK: - Recipe Card

    private func recipeCard(_ entry: RecipeEntry) -> some View {
        VStack(spacing: 16) {
            // タイトルと難易度
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.recipe.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 4) {
                        Text(entry.recipe.difficulty.emoji)
                        Text(entry.recipe.difficulty.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(entry.recipe.difficulty.stars)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                Spacer()
            }

            Divider()

            // メタ情報
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    Text(entry.cookingTimeText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("調理時間")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    Text(entry.caloriesText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("カロリー")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    Text("\(entry.ingredients.count)品")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("食材数")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Steps Section

    private func stepsSection(_ entry: RecipeEntry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("作り方")
                .font(.headline)

            ForEach(Array(entry.recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(.orange, in: Circle())

                    Text(step)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)

                if index < entry.recipe.steps.count - 1 {
                    Rectangle()
                        .fill(.orange.opacity(0.2))
                        .frame(width: 2, height: 12)
                        .padding(.leading, 13)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Ingredients Used Section

    private func ingredientsUsedSection(_ entry: RecipeEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用食材")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(entry.ingredients) { ingredient in
                    HStack(spacing: 4) {
                        Text(ingredient.emoji)
                        Text(ingredient.name)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.orange.opacity(0.1), in: Capsule())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RecipeView(viewModel: CookSnapViewModel())
}
