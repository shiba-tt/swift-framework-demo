import SwiftUI
import SwiftData

// MARK: - ContentView

struct ContentView: View {
    @State private var viewModel = VoiceMemoAIViewModel()
    @State private var selectedTab: Tab = .memos
    @State private var showingRecordView = false
    @Environment(\.modelContext) private var modelContext

    enum Tab: String {
        case memos, stats
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MemoListView(viewModel: viewModel, showingRecordView: $showingRecordView)
                .tabItem {
                    Label("メモ", systemImage: "list.bullet")
                }
                .tag(Tab.memos)

            MemoStatsView(viewModel: viewModel)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(Tab.stats)
        }
        .tint(.indigo)
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .sheet(isPresented: $showingRecordView) {
            RecordMemoView(viewModel: viewModel)
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
