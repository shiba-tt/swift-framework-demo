import SwiftUI

struct HistoryView: View {
    @Bindable var viewModel: CookSnapViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.recipeHistory.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .navigationTitle("履歴")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("レシピ履歴はまだありません")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("生成したレシピがここに表示されます")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }

    // MARK: - History List

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.recipeHistory) { entry in
                    historyCard(entry)
                        .onTapGesture {
                            viewModel.currentRecipe = entry
                            viewModel.selectedTab = .recipe
                        }
                }
            }
            .padding()
        }
    }

    private func historyCard(_ entry: RecipeEntry) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.recipe.name)
                        .font(.headline)

                    HStack(spacing: 8) {
                        Label(entry.recipe.difficulty.displayName, systemImage: "chart.bar.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(entry.cookingTimeText, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(entry.caloriesText, systemImage: "flame")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                ForEach(entry.ingredients.prefix(6)) { ingredient in
                    Text(ingredient.emoji)
                        .font(.title3)
                }
                if entry.ingredients.count > 6 {
                    Text("+\(entry.ingredients.count - 6)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(formattedDate(entry.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView(viewModel: CookSnapViewModel())
}
