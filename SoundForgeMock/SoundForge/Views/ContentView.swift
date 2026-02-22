import SwiftUI

struct ContentView: View {
    @State private var viewModel = SoundForgeViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("グラフ", systemImage: "point.3.connected.trianglepath.dotted",
                value: SoundForgeViewModel.AppTab.graph) {
                NodeGraphView(viewModel: viewModel)
            }
            Tab("プリセット", systemImage: "slider.horizontal.3",
                value: SoundForgeViewModel.AppTab.presets) {
                PresetListView(viewModel: viewModel)
            }
            Tab("プラグイン", systemImage: "puzzlepiece.extension",
                value: SoundForgeViewModel.AppTab.plugins) {
                PluginBrowserView(viewModel: viewModel)
            }
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

#Preview {
    ContentView()
}
