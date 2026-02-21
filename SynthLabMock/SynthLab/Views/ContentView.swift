import SwiftUI

/// メイン画面：タブナビゲーション
struct ContentView: View {
    @State private var viewModel = SynthLabViewModel()

    var body: some View {
        TabView {
            Tab("シンセ", systemImage: "waveform") {
                SynthView(viewModel: viewModel)
            }

            Tab("レッスン", systemImage: "book.fill") {
                LessonListView(viewModel: viewModel)
            }

            Tab("プリセット", systemImage: "square.grid.2x2.fill") {
                PresetListView(viewModel: viewModel)
            }

            Tab("キーボード", systemImage: "pianokeys") {
                KeyboardView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
    }
}
