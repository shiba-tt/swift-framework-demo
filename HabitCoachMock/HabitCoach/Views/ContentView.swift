import SwiftUI

struct ContentView: View {
    @State private var viewModel = HabitCoachViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("今日", systemImage: "checkmark.circle", value: .today) {
                TodayView(viewModel: viewModel)
            }
            Tab("習慣", systemImage: "list.bullet", value: .habits) {
                HabitListView(viewModel: viewModel)
            }
            Tab("インサイト", systemImage: "brain", value: .insights) {
                InsightsView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
    }
}

#Preview {
    ContentView()
}
