import SwiftUI

/// FoodLogAI のメイン画面
struct ContentView: View {
    @State private var viewModel = FoodLogViewModel()

    var body: some View {
        TabView {
            Tab("今日の食事", systemImage: "fork.knife") {
                DashboardView(viewModel: viewModel)
            }
            Tab("撮影", systemImage: "camera.fill") {
                CaptureView(viewModel: viewModel)
            }
            Tab("履歴", systemImage: "chart.bar.fill") {
                HistoryView(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .task {
            await viewModel.initialize()
        }
        .sheet(isPresented: $viewModel.showingAnalysisResult) {
            if let analysis = viewModel.latestAnalysis {
                AnalysisResultView(
                    analysis: analysis,
                    selectedMealType: $viewModel.selectedMealType,
                    onRecord: { viewModel.recordMeal(from: analysis, mealType: viewModel.selectedMealType) }
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
