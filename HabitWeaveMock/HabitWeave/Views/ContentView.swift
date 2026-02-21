import SwiftUI

/// HabitWeave のメイン画面
struct ContentView: View {
    @State private var viewModel = HabitWeaveViewModel()

    var body: some View {
        TabView {
            Tab("今日", systemImage: "calendar") {
                TodayScheduleView(viewModel: viewModel)
            }
            Tab("習慣", systemImage: "list.bullet") {
                HabitListView(viewModel: viewModel)
            }
            Tab("進捗", systemImage: "chart.bar.fill") {
                ProgressView(viewModel: viewModel)
            }
        }
        .tint(.green)
        .task {
            await viewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
