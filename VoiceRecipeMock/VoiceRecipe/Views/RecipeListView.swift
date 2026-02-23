import SwiftUI

struct RecipeListView: View {
    @Bindable var viewModel: VoiceRecipeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    siriPromptBanner
                    if viewModel.searchText.isEmpty {
                        categoryRecipeList
                    } else {
                        filteredRecipeList
                    }
                }
                .padding()
            }
            .navigationTitle("レシピ")
            .searchable(text: $viewModel.searchText, prompt: "レシピを検索")
        }
    }

    // MARK: - Siri Prompt

    private var siriPromptBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text("音声でハンズフリー操作")
                    .font(.headline)
            }

            Text("「Hey Siri、鶏肉のレシピを探して」で検索、調理中は「次のステップ」「タイマー3分」で操作できます。")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                voiceChip("次のステップ", icon: "forward.fill")
                voiceChip("もう一回", icon: "arrow.counterclockwise")
                voiceChip("タイマー", icon: "timer")
            }
        }
        .padding()
        .background(.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func voiceChip(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.orange.opacity(0.15))
        .clipShape(Capsule())
    }

    // MARK: - Category List

    private var categoryRecipeList: some View {
        ForEach(viewModel.recipesByCategory, id: \.category) { group in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(group.category.emoji)
                    Text(group.category.rawValue)
                        .font(.headline)
                }

                ForEach(group.recipes) { recipe in
                    recipeCard(recipe)
                }
            }
        }
    }

    // MARK: - Filtered List

    private var filteredRecipeList: some View {
        ForEach(viewModel.filteredRecipes) { recipe in
            recipeCard(recipe)
        }
    }

    // MARK: - Recipe Card

    private func recipeCard(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: recipe.imageSystemName)
                    .font(.title2)
                    .foregroundStyle(recipe.category.color)
                    .frame(width: 44, height: 44)
                    .background(recipe.category.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.subheadline.bold())
                    HStack(spacing: 8) {
                        Label(recipe.totalTimeText, systemImage: "clock")
                        Label("\(recipe.servings)人分", systemImage: "person.2")
                        Label("\(recipe.steps.count)工程", systemImage: "list.number")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    viewModel.toggleFavorite(recipe)
                } label: {
                    Image(systemName: viewModel.isFavorite(recipe) ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite(recipe) ? .red : .secondary)
                }
            }

            // ステップのプレビュー
            HStack(spacing: 6) {
                ForEach(recipe.steps.prefix(4)) { step in
                    HStack(spacing: 2) {
                        Text("\(step.order)")
                            .font(.caption2.monospacedDigit())
                        if step.hasTimer {
                            Image(systemName: "timer")
                                .font(.system(size: 8))
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.gray.opacity(0.1))
                    .clipShape(Capsule())
                }

                if recipe.steps.count > 4 {
                    Text("+\(recipe.steps.count - 4)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                viewModel.startCooking(recipe: recipe)
            } label: {
                Label("調理を開始", systemImage: "play.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .controlSize(.regular)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RecipeListView(viewModel: VoiceRecipeViewModel())
}
