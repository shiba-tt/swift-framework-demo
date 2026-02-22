import SwiftUI

struct ContentView: View {
    @State private var viewModel = InvisibleWallViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("モニター", systemImage: "shield.fill", value: .monitor) {
                MonitorView(viewModel: viewModel)
            }
            Tab("ゾーン", systemImage: "circle.dashed", value: .zones) {
                ZonesView(viewModel: viewModel)
            }
            Tab("デバイス", systemImage: "antenna.radiowaves.left.and.right", value: .devices) {
                DevicesView(viewModel: viewModel)
            }
            Tab("イベント", systemImage: "list.bullet.rectangle.fill", value: .events) {
                EventsView(viewModel: viewModel)
            }
        }
    }
}
