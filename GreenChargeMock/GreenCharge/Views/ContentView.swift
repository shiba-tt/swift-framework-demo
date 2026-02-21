import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = GreenChargeViewModel()

    var body: some View {
        TabView {
            Tab("ホーム", systemImage: "bolt.fill") {
                HomeView(viewModel: viewModel)
            }

            Tab("グリッド", systemImage: "chart.bar.fill") {
                GridForecastView(viewModel: viewModel)
            }

            Tab("スコア", systemImage: "trophy.fill") {
                ScoreView(viewModel: viewModel)
            }

            Tab("履歴", systemImage: "clock.fill") {
                HistoryView(viewModel: viewModel)
            }
        }
        .tint(.green)
        .task {
            await viewModel.initialize()
        }
    }
}
