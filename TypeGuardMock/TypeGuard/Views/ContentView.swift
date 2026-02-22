import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = TypeGuardViewModel()

    var body: some View {
        Group {
            if viewModel.metricsManager.isAuthorized {
                TabView {
                    Tab("ダッシュボード", systemImage: "gauge.with.dots.needle.50percent") {
                        DashboardView(viewModel: viewModel)
                    }

                    Tab("トレンド", systemImage: "chart.line.uptrend.xyaxis") {
                        TrendView(viewModel: viewModel)
                    }

                    Tab("ベースライン", systemImage: "target") {
                        BaselineView(viewModel: viewModel)
                    }
                }
                .tint(.teal)
            } else {
                PermissionView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.initialize()
        }
    }
}
