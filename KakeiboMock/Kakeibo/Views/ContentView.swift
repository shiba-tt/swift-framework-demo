import SwiftUI

struct ContentView: View {
    @State private var viewModel = KakeiboViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("ホーム", systemImage: "house", value: 0) {
                DashboardView(viewModel: viewModel)
            }

            Tab("支出一覧", systemImage: "list.bullet", value: 1) {
                ExpenseListView(viewModel: viewModel)
            }

            Tab("レポート", systemImage: "chart.pie", value: 2) {
                SummaryView(viewModel: viewModel)
            }

            Tab("設定", systemImage: "gearshape", value: 3) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
