import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @State private var viewModel = PedalBoardViewModel()
    @State private var selectedTab: Tab = .board

    enum Tab: String {
        case board = "ボード"
        case presets = "プリセット"
        case setlist = "セットリスト"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            PedalBoardView(viewModel: viewModel)
                .tabItem {
                    Label("ボード", systemImage: "guitars.fill")
                }
                .tag(Tab.board)

            PresetListView(viewModel: viewModel)
                .tabItem {
                    Label("プリセット", systemImage: "slider.horizontal.3")
                }
                .tag(Tab.presets)

            SetlistView(viewModel: viewModel)
                .tabItem {
                    Label("セットリスト", systemImage: "list.bullet.rectangle")
                }
                .tag(Tab.setlist)
        }
        .tint(.orange)
        .onAppear {
            viewModel.setup()
        }
        .alert("エラー", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
