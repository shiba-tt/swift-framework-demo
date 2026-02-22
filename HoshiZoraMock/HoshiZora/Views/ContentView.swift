import SwiftUI

struct ContentView: View {
    @State private var viewModel = HoshiZoraViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("今夜", systemImage: "moon.stars.fill", value: .tonight) {
                TonightView(viewModel: viewModel)
            }
            Tab("星空予報", systemImage: "calendar", value: .forecast) {
                ForecastView(viewModel: viewModel)
            }
            Tab("観測地", systemImage: "map.fill", value: .spots) {
                SpotsView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    ContentView()
}
