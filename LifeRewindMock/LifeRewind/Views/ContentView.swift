import SwiftUI

/// LifeRewind のメイン画面
struct ContentView: View {
    @State private var viewModel = LifeRewindViewModel()

    var body: some View {
        TabView {
            Tab("今日", systemImage: "clock.arrow.circlepath") {
                OnThisDayView(viewModel: viewModel)
            }
            Tab("サマリー", systemImage: "chart.pie.fill") {
                YearSummaryView(viewModel: viewModel)
            }
            Tab("タイムライン", systemImage: "timeline.selection") {
                TimelineView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
        .task {
            await viewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
