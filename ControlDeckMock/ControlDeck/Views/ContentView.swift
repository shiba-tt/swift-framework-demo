import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @State private var viewModel = ControlDeckViewModel()
    @State private var selectedTab: Tab = .home

    enum Tab: String {
        case home, scenes, activity
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeControlView(viewModel: viewModel)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(Tab.home)

            SceneListView(viewModel: viewModel)
                .tabItem {
                    Label("シーン", systemImage: "sparkles.rectangle.stack.fill")
                }
                .tag(Tab.scenes)

            ActivityLogView(viewModel: viewModel)
                .tabItem {
                    Label("アクティビティ", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.activity)
        }
        .tint(.cyan)
    }
}
