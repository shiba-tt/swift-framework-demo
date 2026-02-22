import SwiftUI

struct ContentView: View {
    @State private var viewModel = LiveVotingViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("イベント", systemImage: "ticket", value: 0) {
                EventListView(viewModel: viewModel)
            }

            Tab("投票", systemImage: "hand.raised.fill", value: 1) {
                if let event = viewModel.selectedEvent {
                    VotingSessionView(viewModel: viewModel, event: event)
                } else {
                    ContentUnavailableView(
                        "イベントを選択",
                        systemImage: "ticket.fill",
                        description: Text("イベントタブからライブイベントを選んでください")
                    )
                }
            }

            Tab("ライトショー", systemImage: "lightbulb.fill", value: 2) {
                LightShowView(viewModel: viewModel)
            }
        }
        .task {
            viewModel.loadEvents()
        }
    }
}

#Preview {
    ContentView()
}
