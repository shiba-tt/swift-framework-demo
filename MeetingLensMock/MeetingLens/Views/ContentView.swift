import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = MeetingLensViewModel()

    var body: some View {
        Group {
            if viewModel.isAuthorized {
                TabView {
                    Tab("ダッシュボード", systemImage: "chart.pie.fill") {
                        DashboardView(viewModel: viewModel)
                    }

                    Tab("ヒートマップ", systemImage: "square.grid.3x3.fill") {
                        HeatmapView(viewModel: viewModel)
                    }

                    Tab("会議一覧", systemImage: "list.bullet.rectangle.fill") {
                        MeetingListView(viewModel: viewModel)
                    }

                    Tab("最適化", systemImage: "lightbulb.fill") {
                        OptimizationView(viewModel: viewModel)
                    }
                }
                .tint(.orange)
            } else {
                PermissionRequestView(viewModel: viewModel)
            }
        }
        .task {
            if viewModel.isAuthorized {
                await viewModel.loadAllData()
            }
        }
    }
}
