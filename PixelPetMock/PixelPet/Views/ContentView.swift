import SwiftUI

/// PixelPet のメイン画面
struct ContentView: View {
    @State private var viewModel = PixelPetViewModel()

    var body: some View {
        TabView {
            Tab("ペット", systemImage: "pawprint.fill") {
                PetView(viewModel: viewModel)
            }
            Tab("ステータス", systemImage: "chart.line.uptrend.xyaxis") {
                PetStatusView(viewModel: viewModel)
            }
            Tab("きろく", systemImage: "clock.arrow.circlepath") {
                PetHistoryView(viewModel: viewModel)
            }
        }
        .tint(.pink)
        .task {
            await viewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
