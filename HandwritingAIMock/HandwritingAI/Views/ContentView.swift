import SwiftUI

struct ContentView: View {
    @State private var viewModel = HandwritingAIViewModel()

    var body: some View {
        TabView {
            Tab("ノート", systemImage: "doc.text") {
                NoteListView(viewModel: viewModel)
            }
            Tab("撮影", systemImage: "camera.fill") {
                CaptureView(viewModel: viewModel)
            }
            Tab("検索", systemImage: "magnifyingglass") {
                SearchView(viewModel: viewModel)
            }
        }
        .tint(.teal)
        .sheet(isPresented: $viewModel.showingNoteDetail) {
            if let note = viewModel.selectedNote {
                NoteDetailView(viewModel: viewModel, note: note)
            }
        }
        .sheet(isPresented: $viewModel.showingOCRResult) {
            if let ocrResult = viewModel.capturedOCRResult {
                OCRResultView(viewModel: viewModel, ocrResult: ocrResult)
            }
        }
    }
}

#Preview {
    ContentView()
}
