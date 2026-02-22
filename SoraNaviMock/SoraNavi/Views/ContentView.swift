import SwiftUI

struct ContentView: View {
    @State private var viewModel = SoraNaviViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("条件", systemImage: "camera.aperture",
                value: SoraNaviViewModel.AppTab.conditions) {
                ConditionsView(viewModel: viewModel)
            }
            Tab("予報", systemImage: "chart.bar.fill",
                value: SoraNaviViewModel.AppTab.forecast) {
                ForecastView(viewModel: viewModel)
            }
            Tab("スポット", systemImage: "map.fill",
                value: SoraNaviViewModel.AppTab.spots) {
                SpotsView(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    ContentView()
}
