import SwiftUI
import SwiftData

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = RoutineViewModel.shared
    @State private var selectedTab: Tab = .routine
    @Environment(\.modelContext) private var modelContext

    enum Tab: Hashable {
        case routine
        case history
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(.routine, systemImage: "alarm.fill") {
                ActiveRoutineView(viewModel: viewModel)
            }

            Tab(.history, systemImage: "calendar") {
                HistoryView()
            }

            Tab(.settings, systemImage: "gearshape.fill") {
                RoutineEditorView(template: viewModel.template)
            }
        }
        .tint(viewModel.themeColor)
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }
}
