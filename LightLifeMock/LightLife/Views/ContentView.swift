import SwiftUI

struct ContentView: View {
    @State private var viewModel = LightLifeViewModel()

    var body: some View {
        TabView {
            Tab("ダッシュボード", systemImage: "sun.max.fill") {
                DashboardView(viewModel: viewModel)
            }

            Tab("タイムライン", systemImage: "chart.bar.fill") {
                LightTimelineView(viewModel: viewModel)
            }

            Tab("週間トレンド", systemImage: "chart.line.uptrend.xyaxis") {
                WeeklyTrendView(viewModel: viewModel)
            }

            Tab("設定", systemImage: "gearshape.fill") {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}
