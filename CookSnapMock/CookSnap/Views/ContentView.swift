import SwiftUI

struct ContentView: View {
    @State private var viewModel = CookSnapViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("スキャン", systemImage: "camera.fill",
                value: CookSnapViewModel.AppTab.scan) {
                ScanView(viewModel: viewModel)
            }
            Tab("レシピ", systemImage: "fork.knife",
                value: CookSnapViewModel.AppTab.recipe) {
                RecipeView(viewModel: viewModel)
            }
            Tab("履歴", systemImage: "clock.fill",
                value: CookSnapViewModel.AppTab.history) {
                HistoryView(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .task {
            await viewModel.prewarmModel()
        }
    }
}

#Preview {
    ContentView()
}
