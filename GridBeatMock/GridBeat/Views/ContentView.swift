import SwiftUI

struct ContentView: View {
    @State private var viewModel = GridBeatViewModel()

    var body: some View {
        TabView {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("\u{30C0}\u{30C3}\u{30B7}\u{30E5}\u{30DC}\u{30FC}\u{30C9}", systemImage: "leaf.fill")
                }

            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("\u{30AB}\u{30EC}\u{30F3}\u{30C0}\u{30FC}", systemImage: "calendar")
                }

            AnnualSummaryView(viewModel: viewModel)
                .tabItem {
                    Label("\u{5E74}\u{9593}\u{30EC}\u{30DD}\u{30FC}\u{30C8}", systemImage: "chart.bar.fill")
                }
        }
        .tint(.green)
        .task {
            await viewModel.loadAllData()
        }
    }
}

#Preview {
    ContentView()
}
