import SwiftUI

struct ContentView: View {
    @State private var viewModel = KiseKaeViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("コーデ", systemImage: "tshirt.fill",
                value: KiseKaeViewModel.AppTab.coordinate) {
                CoordinateView(viewModel: viewModel)
            }
            Tab("時間別", systemImage: "clock.fill",
                value: KiseKaeViewModel.AppTab.forecast) {
                HourlyView(viewModel: viewModel)
            }
            Tab("クローゼット", systemImage: "cabinet.fill",
                value: KiseKaeViewModel.AppTab.closet) {
                ClosetView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    ContentView()
}
