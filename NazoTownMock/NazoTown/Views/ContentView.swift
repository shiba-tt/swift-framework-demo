import SwiftUI

struct ContentView: View {
    @State private var viewModel = NazoTownViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("冒険", systemImage: "map", value: 0) {
                AdventureListView(viewModel: viewModel)
            }

            Tab("進行中", systemImage: "puzzlepiece.extension", value: 1) {
                if viewModel.isAdventureActive {
                    PuzzleSolveView(viewModel: viewModel)
                } else {
                    ContentUnavailableView(
                        "冒険を開始しよう",
                        systemImage: "map.circle",
                        description: Text("冒険タブからコースを選んでスタートしてください")
                    )
                }
            }

            Tab("記録", systemImage: "trophy", value: 2) {
                AdventureProgressView(viewModel: viewModel)
            }
        }
        .task {
            viewModel.loadAdventures()
        }
    }
}

#Preview {
    ContentView()
}
