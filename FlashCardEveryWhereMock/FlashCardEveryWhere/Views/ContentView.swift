import SwiftUI

struct ContentView: View {
    @State private var viewModel = FlashCardViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("ホーム", systemImage: "house.fill", value: .home) {
                HomeView(viewModel: viewModel)
            }
            Tab("デッキ", systemImage: "rectangle.stack.fill", value: .decks) {
                DeckListView(viewModel: viewModel)
            }
            Tab("学習", systemImage: "brain.head.profile", value: .study) {
                StudyView(viewModel: viewModel)
            }
            Tab("統計", systemImage: "chart.bar.fill", value: .stats) {
                StatsView(viewModel: viewModel)
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = viewModel.toastMessage {
                toastView(toast)
            }
        }
    }

    private func toastView(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 60)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring, value: viewModel.toastMessage)
    }
}

#Preview {
    ContentView()
}
