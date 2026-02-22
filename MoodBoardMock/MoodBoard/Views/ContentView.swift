import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = MoodBoardViewModel()

    var body: some View {
        TabView {
            Tab("記録", systemImage: "face.smiling.fill") {
                MoodInputView(viewModel: viewModel)
            }

            Tab("履歴", systemImage: "calendar") {
                MoodHistoryView(viewModel: viewModel)
            }

            Tab("統計", systemImage: "chart.bar.fill") {
                MoodStatsView(viewModel: viewModel)
            }
        }
        .tint(.pink)
        .task {
            await viewModel.initialize()
        }
    }
}
