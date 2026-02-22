import SwiftUI

struct ContentView: View {
    @State private var viewModel = TenKiLogViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("タイムライン", systemImage: "clock.fill", value: .timeline) {
                TimelineView(viewModel: viewModel)
            }
            Tab("カレンダー", systemImage: "calendar", value: .calendar) {
                CalendarView(viewModel: viewModel)
            }
            Tab("分析", systemImage: "chart.bar.xaxis", value: .insights) {
                InsightsView(viewModel: viewModel)
            }
            Tab("統計", systemImage: "chart.pie.fill", value: .stats) {
                StatsView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
