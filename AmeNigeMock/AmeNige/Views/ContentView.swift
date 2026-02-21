import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = AmeNigeViewModel()

    var body: some View {
        Group {
            if viewModel.locationManager.isAuthorized {
                TabView {
                    Tab("ダッシュボード", systemImage: "umbrella.fill") {
                        DashboardView(viewModel: viewModel)
                    }

                    Tab("降水グラフ", systemImage: "chart.bar.fill") {
                        PrecipitationChartView(viewModel: viewModel)
                    }

                    Tab("時間別", systemImage: "clock.fill") {
                        HourlyForecastView(viewModel: viewModel)
                    }
                }
                .tint(.cyan)
            } else {
                LocationPermissionView(viewModel: viewModel)
            }
        }
        .task {
            if viewModel.locationManager.isAuthorized {
                await viewModel.refresh()
            }
        }
    }
}
