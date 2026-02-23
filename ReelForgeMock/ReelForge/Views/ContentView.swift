import SwiftUI

struct ContentView: View {
    @State private var viewModel = ReelForgeViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("作成", systemImage: "wand.and.stars", value: .create) {
                CreateView(viewModel: viewModel)
            }
            Tab("プロジェクト", systemImage: "film.stack", value: .projects) {
                ProjectListView(viewModel: viewModel)
            }
            Tab("ライブラリ", systemImage: "photo.on.rectangle.angled", value: .library) {
                LibraryView(viewModel: viewModel)
            }
        }
        .tint(.purple)
    }
}
