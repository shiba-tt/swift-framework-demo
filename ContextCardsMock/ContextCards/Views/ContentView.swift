import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContextCardsViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("スキャン", systemImage: "camera.fill",
                value: ContextCardsViewModel.AppTab.scan) {
                ScanView(viewModel: viewModel)
            }
            Tab("名刺", systemImage: "person.crop.rectangle.stack.fill",
                value: ContextCardsViewModel.AppTab.contacts) {
                ContactListView(viewModel: viewModel)
            }
            Tab("お気に入り", systemImage: "star.fill",
                value: ContextCardsViewModel.AppTab.favorites) {
                FavoritesView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
        .task {
            await viewModel.prewarmModel()
        }
    }
}

#Preview {
    ContentView()
}
