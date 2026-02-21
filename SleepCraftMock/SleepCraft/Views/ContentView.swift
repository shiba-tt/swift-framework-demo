import SwiftUI
import SwiftData

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = SleepViewModel.shared
    @State private var selectedTab: Tab = .alarm
    @Environment(\.modelContext) private var modelContext

    enum Tab: Hashable {
        case alarm
        case history
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(.alarm, systemImage: "bed.double.fill") {
                AlarmView(viewModel: viewModel)
            }

            Tab(.history, systemImage: "chart.xyaxis.line") {
                SleepHistoryView()
            }

            Tab(.settings, systemImage: "gearshape.fill") {
                AlarmSettingsView(viewModel: viewModel)
            }
        }
        .tint(viewModel.themeColor)
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }
}
