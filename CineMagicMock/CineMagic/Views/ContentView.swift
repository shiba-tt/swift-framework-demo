import SwiftUI

struct ContentView: View {
    @State private var viewModel = CineMagicViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("撮影", systemImage: "camera.filters",
                value: CineMagicViewModel.AppTab.camera) {
                CameraView(viewModel: viewModel)
            }
            Tab("ギャラリー", systemImage: "photo.stack",
                value: CineMagicViewModel.AppTab.gallery) {
                GalleryView(viewModel: viewModel)
            }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
