import SwiftUI

/// WidgetQuest のメイン画面
struct ContentView: View {
    @State private var viewModel = WidgetQuestViewModel()

    var body: some View {
        TabView {
            Tab("冒険", systemImage: "map.fill") {
                QuestView(viewModel: viewModel)
            }
            Tab("勇者", systemImage: "person.fill") {
                HeroStatusView(viewModel: viewModel)
            }
            Tab("記録", systemImage: "scroll.fill") {
                QuestLogView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
        .task {
            await viewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
