import SwiftUI

struct ContentView: View {
    @State private var viewModel = VoiceRecipeViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("レシピ", systemImage: "book.fill", value: .recipes) {
                RecipeListView(viewModel: viewModel)
            }
            Tab("調理中", systemImage: "flame.fill", value: .cooking) {
                CookingView(viewModel: viewModel)
            }
            Tab("履歴", systemImage: "clock.fill", value: .history) {
                CommandHistoryView(viewModel: viewModel)
            }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
