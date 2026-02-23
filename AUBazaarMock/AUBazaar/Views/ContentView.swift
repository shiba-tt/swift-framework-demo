import SwiftUI

struct ContentView: View {
    @State private var viewModel = AUBazaarViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("ブラウズ", systemImage: "square.grid.2x2", value: .browse) {
                BrowseView(viewModel: viewModel)
            }
            Tab("A/B 比較", systemImage: "arrow.left.arrow.right", value: .compare) {
                CompareView(viewModel: viewModel)
            }
            Tab("お気に入り", systemImage: "heart", value: .favorites) {
                FavoritesView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
    }
}
