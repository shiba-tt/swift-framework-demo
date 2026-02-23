import SwiftUI

struct ContentView: View {
    @State private var viewModel = AIFormCoachViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("ワークアウト", systemImage: "figure.strengthtraining.traditional", value: .workout) {
                WorkoutView(viewModel: viewModel)
            }
            Tab("分析", systemImage: "waveform.path.ecg", value: .analysis) {
                AnalysisView(viewModel: viewModel)
            }
            Tab("履歴", systemImage: "chart.line.uptrend.xyaxis", value: .history) {
                HistoryView(viewModel: viewModel)
            }
        }
        .tint(.cyan)
    }
}

#Preview {
    ContentView()
}
