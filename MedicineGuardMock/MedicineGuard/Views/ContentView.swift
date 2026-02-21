import SwiftUI
import SwiftData

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = MedicationViewModel.shared
    @State private var selectedTab: Tab = .today
    @Environment(\.modelContext) private var modelContext

    enum Tab: Hashable {
        case today
        case medications
        case history
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(.today, systemImage: "pills.fill") {
                TodayView(viewModel: viewModel)
            }

            Tab(.medications, systemImage: "list.bullet.clipboard.fill") {
                MedicationListView(viewModel: viewModel)
            }

            Tab(.history, systemImage: "calendar") {
                MedicationHistoryView()
            }
        }
        .tint(.blue)
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }
}
