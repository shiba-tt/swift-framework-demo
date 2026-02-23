import SwiftUI

struct ContentView: View {
    @State private var viewModel = ARMuseumViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("展覧会", systemImage: "building.columns", value: 0) {
                GalleryView(viewModel: viewModel)
            }

            Tab("作品", systemImage: "photo.artframe", value: 1) {
                ArtworkListView(viewModel: viewModel)
            }

            Tab("AR展示", systemImage: "arkit", value: 2) {
                if viewModel.isARActive, let exhibition = viewModel.selectedExhibition {
                    ARExhibitionView(viewModel: viewModel, exhibition: exhibition)
                } else {
                    ContentUnavailableView(
                        "展覧会を選択",
                        systemImage: "arkit",
                        description: Text("展覧会タブからAR展示を開始してください")
                    )
                }
            }

            Tab("ルーム", systemImage: "room", value: 3) {
                RoomScanView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
        .sheet(isPresented: $viewModel.showingArtworkDetail) {
            if let artwork = viewModel.selectedArtwork {
                ArtworkDetailView(viewModel: viewModel, artwork: artwork)
            }
        }
        .sheet(isPresented: $viewModel.showingAddArtwork) {
            AddArtworkView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
