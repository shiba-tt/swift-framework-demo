import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContextDJViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("DJ", systemImage: "music.note", value: 0) {
                NowPlayingView(viewModel: viewModel)
            }

            Tab("プレイリスト", systemImage: "list.bullet", value: 1) {
                PlaylistView(viewModel: viewModel)
            }

            Tab("コンテキスト", systemImage: "slider.horizontal.3", value: 2) {
                ContextSettingsView(viewModel: viewModel)
            }
        }
        .task {
            viewModel.loadInitialState()
        }
    }
}

#Preview {
    ContentView()
}
