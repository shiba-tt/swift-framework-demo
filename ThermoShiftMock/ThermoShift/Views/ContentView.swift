import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = ThermoShiftViewModel()

    var body: some View {
        TabView {
            Tab("ホーム", systemImage: "thermometer.medium") {
                HomeView(viewModel: viewModel)
            }

            Tab("運転プラン", systemImage: "calendar.badge.clock") {
                PlanView(viewModel: viewModel)
            }

            Tab("グリッド", systemImage: "chart.bar.fill") {
                GridPriceView(viewModel: viewModel)
            }

            Tab("レポート", systemImage: "doc.text.fill") {
                ReportView(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .task {
            await viewModel.initialize()
        }
    }
}
