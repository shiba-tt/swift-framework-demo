import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = LiveBoardViewModel()

    var body: some View {
        TabView {
            Tab("チーム", systemImage: "person.3.fill") {
                TeamStatusView(viewModel: viewModel)
            }

            Tab("タスク", systemImage: "checklist") {
                TaskListView(viewModel: viewModel)
            }

            Tab("設定", systemImage: "gearshape.fill") {
                BoardSettingsView(viewModel: viewModel)
            }
        }
        .tint(.blue)
        .task {
            await viewModel.initialize()
        }
    }
}
