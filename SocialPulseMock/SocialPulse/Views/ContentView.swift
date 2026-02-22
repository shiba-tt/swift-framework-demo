import SwiftUI

/// SocialPulse のメイン画面
struct ContentView: View {
    @State private var viewModel = SocialPulseViewModel()

    var body: some View {
        TabView {
            Tab("ダッシュボード", systemImage: "heart.circle.fill") {
                DashboardView(viewModel: viewModel)
            }
            Tab("コミュニケーション", systemImage: "phone.fill") {
                CommunicationView(viewModel: viewModel)
            }
            Tab("訪問分析", systemImage: "mappin.and.ellipse") {
                VisitAnalysisView(viewModel: viewModel)
            }
            Tab("週間レポート", systemImage: "chart.bar.fill") {
                WeeklyReportView(viewModel: viewModel)
            }
        }
        .tint(.pink)
        .task {
            await viewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
