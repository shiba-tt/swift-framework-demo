import SwiftUI

struct ContentView: View {
    @State private var viewModel = SmartSnapViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("アルバム", systemImage: "rectangle.stack.fill",
                value: SmartSnapViewModel.AppTab.albums) {
                AlbumListView(viewModel: viewModel)
            }
            Tab("写真", systemImage: "photo.fill",
                value: SmartSnapViewModel.AppTab.photos) {
                PhotoListView(viewModel: viewModel)
            }
            Tab("検索", systemImage: "magnifyingglass",
                value: SmartSnapViewModel.AppTab.search) {
                SearchView(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .task {
            await viewModel.loadPhotos()
            await viewModel.prewarmModel()
        }
    }
}

#Preview {
    ContentView()
}
