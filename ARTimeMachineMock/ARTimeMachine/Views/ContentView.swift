import SwiftUI

struct ContentView: View {
    @State private var viewModel = ARTimeMachineViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("スポット", systemImage: "map.fill", value: 0) {
                SpotListView(viewModel: viewModel)
            }

            Tab("タイムトラベル", systemImage: "clock.arrow.circlepath", value: 1) {
                if let spot = viewModel.selectedSpot, viewModel.isARActive {
                    ARTimeView(viewModel: viewModel, spot: spot)
                } else {
                    ContentUnavailableView(
                        "スポットを選択",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("スポットタブから歴史スポットを選んでARを開始してください")
                    )
                }
            }

            Tab("マップ", systemImage: "mappin.and.ellipse", value: 2) {
                NearbyMapView(viewModel: viewModel)
            }

            Tab("コレクション", systemImage: "photo.on.rectangle.angled", value: 3) {
                CollectionView(viewModel: viewModel)
            }
        }
        .tint(.indigo)
        .sheet(isPresented: $viewModel.showingSpotDetail) {
            if let spot = viewModel.selectedSpot {
                SpotDetailSheet(viewModel: viewModel, spot: spot)
            }
        }
        .sheet(isPresented: $viewModel.showingPhotoCapture) {
            PhotoCaptureSheet(viewModel: viewModel)
        }
        .onChange(of: viewModel.isARActive) { _, isActive in
            if isActive {
                selectedTab = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
