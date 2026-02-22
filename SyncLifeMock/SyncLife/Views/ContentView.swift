import SwiftUI

struct ContentView: View {
    @State private var viewModel = SyncLifeViewModel()

    var body: some View {
        TabView {
            FamilyOverviewView(viewModel: viewModel)
                .tabItem {
                    Label("\u{30DB}\u{30FC}\u{30E0}", systemImage: "house.fill")
                }

            AvailabilityView(viewModel: viewModel)
                .tabItem {
                    Label("\u{7A7A}\u{304D}\u{6642}\u{9593}", systemImage: "clock.fill")
                }

            SharedTasksView(viewModel: viewModel)
                .tabItem {
                    Label("\u{30BF}\u{30B9}\u{30AF}", systemImage: "checklist")
                }
        }
        .tint(.blue)
        .task {
            await viewModel.loadAllData()
        }
    }
}

#Preview {
    ContentView()
}
