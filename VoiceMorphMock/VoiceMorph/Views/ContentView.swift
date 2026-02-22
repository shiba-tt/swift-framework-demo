import SwiftUI

struct ContentView: View {
    @State private var viewModel = VoiceMorphViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("モーフ", systemImage: "waveform.circle.fill",
                value: VoiceMorphViewModel.AppTab.morph) {
                MorphView(viewModel: viewModel)
            }
            Tab("録音", systemImage: "list.bullet",
                value: VoiceMorphViewModel.AppTab.recordings) {
                RecordingsView(viewModel: viewModel)
            }
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView()
}
