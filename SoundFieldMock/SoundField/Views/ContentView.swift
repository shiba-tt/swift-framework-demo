import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = SoundFieldViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("フィールド", systemImage: "dot.radiowaves.left.and.right",
                value: SoundFieldViewModel.AppTab.field) {
                SoundFieldView(viewModel: viewModel)
            }
            Tab("トラック", systemImage: "music.note.list",
                value: SoundFieldViewModel.AppTab.tracks) {
                TrackListView(viewModel: viewModel)
            }
            Tab("ミキサー", systemImage: "slider.horizontal.3",
                value: SoundFieldViewModel.AppTab.mixer) {
                MixerView(viewModel: viewModel)
            }
            Tab("設定", systemImage: "gearshape.fill",
                value: SoundFieldViewModel.AppTab.settings) {
                SettingsView(viewModel: viewModel)
            }
        }
        .tint(.green)
        .task {
            viewModel.startSession()
        }
    }
}

#Preview {
    ContentView()
}
