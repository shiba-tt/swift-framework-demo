import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = VoiceStudioViewModel()

    var body: some View {
        TabView {
            Tab("収録", systemImage: "mic.fill") {
                RecordingView(viewModel: viewModel)
            }

            Tab("エフェクト", systemImage: "slider.horizontal.3") {
                EffectChainView(viewModel: viewModel)
            }

            Tab("セッション", systemImage: "list.bullet") {
                SessionListView(viewModel: viewModel)
            }
        }
        .tint(.purple)
        .onAppear {
            viewModel.setup()
        }
    }
}
