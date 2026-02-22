import SwiftUI

/// ChronoSense のメイン画面
struct ContentView: View {
    @State private var viewModel = ChronoSenseViewModel()

    var body: some View {
        TabView {
            Tab("クロノグラフ", systemImage: "clock.fill") {
                ChronographView(viewModel: viewModel)
            }
            Tab("センサー詳細", systemImage: "waveform.path.ecg") {
                SensorDetailView(viewModel: viewModel)
            }
            Tab("週間レポート", systemImage: "chart.bar.fill") {
                WeeklyReportView(viewModel: viewModel)
            }
            Tab("アドバイス", systemImage: "lightbulb.fill") {
                AdviceView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
        .task {
            await viewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
