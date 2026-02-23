import SwiftUI

struct ContentView: View {
    @State private var viewModel = ARShadowViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("ステージ", systemImage: "list.star", value: 0) {
                StageListView(viewModel: viewModel)
            }

            Tab("ARパズル", systemImage: "arkit", value: 1) {
                if viewModel.isPlaying, let stage = viewModel.selectedStage {
                    ARPuzzleView(viewModel: viewModel, stage: stage)
                } else {
                    ContentUnavailableView(
                        "ステージを選択",
                        systemImage: "puzzlepiece.extension",
                        description: Text("ステージタブからパズルを選んで開始してください")
                    )
                }
            }

            Tab("スキャン", systemImage: "camera.metering.spot", value: 2) {
                RoomScanView(viewModel: viewModel)
            }

            Tab("記録", systemImage: "chart.bar.fill", value: 3) {
                StatsView(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .sheet(isPresented: $viewModel.showingResult) {
            if let result = viewModel.lastResult {
                ResultView(viewModel: viewModel, result: result)
            }
        }
        .sheet(isPresented: $viewModel.showingCoop) {
            CoopView(viewModel: viewModel)
        }
        .onChange(of: viewModel.isPlaying) { _, isPlaying in
            if isPlaying {
                selectedTab = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
