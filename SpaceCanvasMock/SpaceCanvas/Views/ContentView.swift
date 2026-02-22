import SwiftUI

struct ContentView: View {
    @State private var viewModel = SpaceCanvasViewModel()

    var body: some View {
        TabView(selection: Binding(
            get: { viewModel.selectedTab },
            set: { viewModel.selectedTab = $0 }
        )) {
            Tab("キャンバス", systemImage: "paintbrush.pointed.fill",
                value: SpaceCanvasViewModel.AppTab.canvas) {
                CanvasView(viewModel: viewModel)
            }
            Tab("ギャラリー", systemImage: "photo.stack",
                value: SpaceCanvasViewModel.AppTab.gallery) {
                GalleryView(viewModel: viewModel)
            }
            Tab("アーティスト", systemImage: "person.3.fill",
                value: SpaceCanvasViewModel.AppTab.artists) {
                ArtistsView(viewModel: viewModel)
            }
        }
        .tint(.cyan)
    }
}
