import SwiftUI

struct ContentView: View {
    @State private var viewModel = AllergyGuardViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("メニュー", systemImage: "menucard", value: 0) {
                MenuListView(viewModel: viewModel)
            }

            Tab("アレルギー設定", systemImage: "shield.checkered", value: 1) {
                AllergenSelectionView(viewModel: viewModel)
            }

            Tab("安全サマリー", systemImage: "chart.pie", value: 2) {
                SafetySummaryView(viewModel: viewModel)
            }
        }
        .task {
            viewModel.loadRestaurant()
        }
    }
}

#Preview {
    ContentView()
}
