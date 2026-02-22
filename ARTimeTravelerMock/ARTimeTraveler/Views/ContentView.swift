import SwiftUI

struct ContentView: View {
    @State private var viewModel = ARTimeTravelerViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("スポット", systemImage: "map", value: 0) {
                SpotListView(viewModel: viewModel)
            }

            Tab("AR体験", systemImage: "camera.viewfinder", value: 1) {
                if viewModel.isARActive {
                    ARExperienceView(viewModel: viewModel)
                } else {
                    ContentUnavailableView(
                        "スポットを選択",
                        systemImage: "camera.viewfinder",
                        description: Text("スポットタブから歴史スポットを選んでAR体験を開始してください")
                    )
                }
            }

            Tab("記録", systemImage: "clock.arrow.circlepath", value: 2) {
                VisitHistoryView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
