import SwiftUI
import SwiftData

// MARK: - ContentView

struct ContentView: View {
    @State private var viewModel = DreamJournalViewModel()
    @State private var selectedTab: Tab = .journal
    @Environment(\.modelContext) private var modelContext

    enum Tab: String {
        case journal = "日記"
        case calendar = "カレンダー"
        case stats = "統計"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DreamListView(viewModel: viewModel)
                .tabItem {
                    Label("日記", systemImage: "book.closed.fill")
                }
                .tag(Tab.journal)

            DreamCalendarView(viewModel: viewModel)
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(Tab.calendar)

            DreamStatsView(viewModel: viewModel)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(Tab.stats)
        }
        .tint(.purple)
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .alert("エラー", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
