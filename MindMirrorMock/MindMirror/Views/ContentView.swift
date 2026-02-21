import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = MindMirrorViewModel()

    var body: some View {
        Group {
            if viewModel.sensorKitManager.isAuthorized {
                TabView {
                    Tab("ダッシュボード", systemImage: "heart.text.clipboard.fill") {
                        DashboardView(viewModel: viewModel)
                    }

                    Tab("センサー", systemImage: "sensor.fill") {
                        SensorDetailView(viewModel: viewModel)
                    }

                    Tab("週間レポート", systemImage: "chart.line.uptrend.xyaxis") {
                        WeeklyReportView(viewModel: viewModel)
                    }
                }
                .tint(.purple)
            } else {
                PermissionView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.initialize()
        }
    }
}
