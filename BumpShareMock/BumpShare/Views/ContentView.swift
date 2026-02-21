import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = BumpShareViewModel()

    var body: some View {
        TabView {
            Tab("共有", systemImage: "wave.3.right") {
                ShareRadarView(viewModel: viewModel)
            }

            Tab("コンテンツ", systemImage: "doc.fill") {
                ContentListView(viewModel: viewModel)
            }

            Tab("履歴", systemImage: "clock.fill") {
                HistoryView(viewModel: viewModel)
            }

            Tab("設定", systemImage: "gearshape.fill") {
                SettingsView(viewModel: viewModel)
            }
        }
        .tint(.cyan)
        .task {
            viewModel.startDiscovery()
        }
    }
}
