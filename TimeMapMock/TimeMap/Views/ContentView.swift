import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = TimeMapViewModel()
    @State private var selectedTab: Tab = .map

    enum Tab: Hashable {
        case map
        case timeline
        case stats
    }

    var body: some View {
        Group {
            if viewModel.isAuthorized {
                TabView(selection: $selectedTab) {
                    Tab(.map, systemImage: "map.fill") {
                        MapScheduleView(viewModel: viewModel)
                    }

                    Tab(.timeline, systemImage: "calendar.day.timeline.leading") {
                        TimelineView(viewModel: viewModel)
                    }

                    Tab(.stats, systemImage: "chart.bar.fill") {
                        DayStatsView(viewModel: viewModel)
                    }
                }
                .tint(.indigo)
            } else {
                PermissionRequestView(viewModel: viewModel)
            }
        }
        .task {
            if viewModel.isAuthorized {
                await viewModel.loadEvents()
            }
        }
    }
}
