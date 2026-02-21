import SwiftUI
import SwiftData

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = AdventureViewModel.shared
    @State private var selectedTab: Tab = .map
    @Environment(\.modelContext) private var modelContext

    enum Tab: Hashable {
        case map
        case spots
        case ranking
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(.map, systemImage: "map.fill") {
                SpotMapView(viewModel: viewModel)
            }

            Tab(.spots, systemImage: "list.bullet") {
                SpotListView(viewModel: viewModel)
            }

            Tab(.ranking, systemImage: "trophy.fill") {
                RankingView(viewModel: viewModel)
            }
        }
        .tint(viewModel.themeColor)
        .onAppear {
            viewModel.configure(modelContext: modelContext)
            viewModel.requestLocationAuth()
        }
    }
}
