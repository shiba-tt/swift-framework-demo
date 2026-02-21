import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = GridPulseViewModel()

    var body: some View {
        TabView {
            Tab("アート", systemImage: "paintpalette.fill") {
                ArtView(viewModel: viewModel)
            }

            Tab("タイムライン", systemImage: "chart.bar.fill") {
                TimelineView(viewModel: viewModel)
            }

            Tab("サマリー", systemImage: "leaf.fill") {
                SummaryView(viewModel: viewModel)
            }
        }
        .tint(.green)
        .task {
            await viewModel.initialize()
        }
    }
}
