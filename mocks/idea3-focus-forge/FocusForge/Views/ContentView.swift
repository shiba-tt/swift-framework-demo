import SwiftUI
import SwiftData

/// メイン画面：タイマー表示 + タブナビゲーション
struct ContentView: View {
    @State private var viewModel = PomodoroViewModel.shared
    @State private var selectedTab: Tab = .timer
    @Environment(\.modelContext) private var modelContext

    enum Tab: Hashable {
        case timer
        case history
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(.timer, systemImage: "timer") {
                TimerView(viewModel: viewModel)
            }

            Tab(.history, systemImage: "chart.bar.fill") {
                SessionHistoryView()
            }

            Tab(.settings, systemImage: "gearshape.fill") {
                SettingsView(settings: viewModel.settings)
            }
        }
        .tint(viewModel.themeColor)
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }
}

// MARK: - Tab Label

private extension ContentView.Tab {
    var title: String {
        switch self {
        case .timer: "タイマー"
        case .history: "履歴"
        case .settings: "設定"
        }
    }
}
