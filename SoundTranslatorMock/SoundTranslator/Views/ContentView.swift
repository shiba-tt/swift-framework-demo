import SwiftUI

struct ContentView: View {
    @State private var viewModel = SoundTranslatorViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("リスニング", systemImage: "ear.fill", value: 0) {
                ListeningView(viewModel: viewModel)
            }

            Tab("履歴", systemImage: "clock.fill", value: 1) {
                HistoryView(viewModel: viewModel)
            }

            Tab("プロファイル", systemImage: "person.crop.circle", value: 2) {
                ProfileView(viewModel: viewModel)
            }

            Tab("設定", systemImage: "gearshape.fill", value: 3) {
                SettingsView(viewModel: viewModel)
            }
        }
        .tint(.teal)
    }
}

#Preview {
    ContentView()
}
