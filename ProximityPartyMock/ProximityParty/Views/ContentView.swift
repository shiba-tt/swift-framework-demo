import SwiftUI

struct ContentView: View {
    @State private var viewModel = ProximityPartyViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.session != nil {
                GameFieldView(viewModel: viewModel)
            } else {
                LobbyView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showResults) {
            ResultsView(viewModel: viewModel)
        }
    }
}
