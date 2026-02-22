import SwiftUI

struct ContentView: View {
    @State private var viewModel = WatchPartyViewModel()

    var body: some View {
        TabView(selection: Binding(
            get: { viewModel.selectedTab },
            set: { viewModel.selectedTab = $0 }
        )) {
            Tab("パーティ", systemImage: "play.rectangle.fill",
                value: WatchPartyViewModel.AppTab.party) {
                PartyView(viewModel: viewModel)
            }
            Tab("ライブラリ", systemImage: "film.stack",
                value: WatchPartyViewModel.AppTab.library) {
                LibraryView(viewModel: viewModel)
            }
            Tab("履歴", systemImage: "clock.fill",
                value: WatchPartyViewModel.AppTab.history) {
                HistoryView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
    }
}
