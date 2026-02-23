import SwiftUI

struct ContentView: View {
    @State private var viewModel = ARFitnessCoachViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("エクササイズ", systemImage: "figure.run", value: 0) {
                ExerciseListView(viewModel: viewModel)
            }

            Tab("トレーニング", systemImage: "arkit", value: 1) {
                if viewModel.isTraining, let exercise = viewModel.selectedExercise {
                    ARTrainingView(viewModel: viewModel, exercise: exercise)
                } else {
                    ContentUnavailableView(
                        "エクササイズを選択",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("エクササイズタブから種目を選んでトレーニングを開始してください")
                    )
                }
            }

            Tab("履歴", systemImage: "chart.bar.fill", value: 2) {
                HistoryView(viewModel: viewModel)
            }

            Tab("統計", systemImage: "chart.line.uptrend.xyaxis", value: 3) {
                StatsView(viewModel: viewModel)
            }
        }
        .tint(.green)
        .sheet(isPresented: $viewModel.showingExerciseDetail) {
            if let exercise = viewModel.selectedExercise {
                ExerciseDetailSheet(viewModel: viewModel, exercise: exercise)
            }
        }
        .sheet(isPresented: $viewModel.showingResult) {
            if let session = viewModel.lastSession {
                ResultSheet(viewModel: viewModel, session: session)
            }
        }
        .onChange(of: viewModel.isTraining) { _, isTraining in
            if isTraining {
                selectedTab = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
