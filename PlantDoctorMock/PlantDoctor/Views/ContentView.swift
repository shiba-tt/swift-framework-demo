import SwiftUI

/// PlantDoctor のメイン画面
struct ContentView: View {
    @State private var viewModel = PlantDoctorViewModel()

    var body: some View {
        TabView {
            Tab("マイ植物", systemImage: "leaf.fill") {
                PlantListView(viewModel: viewModel)
            }
            Tab("診断", systemImage: "camera.viewfinder") {
                CaptureView(viewModel: viewModel)
            }
            Tab("ケア", systemImage: "calendar") {
                CareScheduleView(viewModel: viewModel)
            }
        }
        .tint(.green)
        .task {
            await viewModel.initialize()
        }
        .sheet(isPresented: $viewModel.showingDiagnosis) {
            if let diagnosis = viewModel.latestDiagnosis {
                DiagnosisView(diagnosis: diagnosis)
            }
        }
    }
}

#Preview {
    ContentView()
}
