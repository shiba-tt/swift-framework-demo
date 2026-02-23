import SwiftUI

struct ContentView: View {
    @State private var viewModel = SoundScapeViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("分析", systemImage: "waveform", value: .analyze) {
                AnalyzeView(viewModel: viewModel)
            }
            Tab("ログ", systemImage: "list.bullet.rectangle", value: .log) {
                SoundLogView(viewModel: viewModel)
            }
            Tab("統計", systemImage: "chart.bar", value: .stats) {
                StatsView(viewModel: viewModel)
            }
        }
        .tint(.cyan)
    }
}

#Preview {
    ContentView()
}
