import SwiftUI

/// WattWise のメイン画面
struct ContentView: View {
    @State private var viewModel = WattWiseViewModel()

    var body: some View {
        TabView {
            Tab("ホーム", systemImage: "house.fill") {
                FamilyDashboardView(viewModel: viewModel)
            }
            Tab("クイズ", systemImage: "gamecontroller.fill") {
                QuizView(viewModel: viewModel)
            }
            Tab("レポート", systemImage: "chart.bar.fill") {
                ReportView(viewModel: viewModel)
            }
        }
        .tint(.green)
        .task {
            await viewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
