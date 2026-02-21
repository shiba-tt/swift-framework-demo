import SwiftUI
import MapKit

/// スポットマップ画面
struct SpotMapView: View {
    @Bindable var viewModel: AdventureViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedSpot: PuzzleSpot?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 地図
                Map(position: $cameraPosition, selection: $selectedSpot) {
                    ForEach(viewModel.spots) { spot in
                        Annotation(spot.name, coordinate: spot.coordinate, anchor: .bottom) {
                            spotPin(spot)
                        }
                        .tag(spot)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))

                // 下部パネル
                VStack(spacing: 12) {
                    // 進捗バー
                    progressBar

                    // 選択中のスポット情報
                    if let spot = selectedSpot {
                        spotInfoCard(spot)
                    } else if let next = viewModel.nextSpot {
                        nextSpotHint(next)
                    } else if viewModel.isAllCleared {
                        allClearedBanner
                    }
                }
                .padding()
            }
            .navigationTitle("NazoWalk")
            .sheet(item: $viewModel.selectedSpot) { spot in
                PuzzleView(viewModel: viewModel, spot: spot)
            }
        }
    }

    // MARK: - Components

    private func spotPin(_ spot: PuzzleSpot) -> some View {
        VStack(spacing: 2) {
            Image(systemName: viewModel.isSpotCleared(spot) ? "checkmark.circle.fill" : "questionmark.circle.fill")
                .font(.title2)
                .foregroundStyle(viewModel.isSpotCleared(spot) ? .green : .orange)
                .background(
                    Circle()
                        .fill(.white)
                        .frame(width: 32, height: 32)
                )
            Text(spot.name)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }

    private var progressBar: some View {
        VStack(spacing: 4) {
            HStack {
                Text("進捗")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.currentProgress?.clearedCount ?? 0)/\(viewModel.spots.count)")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            ProgressView(value: viewModel.progressRatio)
                .tint(.orange)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    private func spotInfoCard(_ spot: PuzzleSpot) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.orange)
                    Text(spot.name)
                        .font(.headline)
                }

                Text(spot.spotDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.isSpotCleared(spot) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            } else {
                Button("挑戦") {
                    viewModel.startPuzzle(at: spot)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }

    private func nextSpotHint(_ spot: PuzzleSpot) -> some View {
        HStack {
            Image(systemName: "location.magnifyingglass")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("次のスポット")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(spot.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()

            Button("ナビ") {
                selectedSpot = spot
                cameraPosition = .region(MKCoordinateRegion(
                    center: spot.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }

    private var allClearedBanner: some View {
        HStack {
            Image(systemName: "party.popper.fill")
                .font(.title2)

            VStack(alignment: .leading) {
                Text("全クリア!")
                    .font(.headline)
                Text("合計 \(viewModel.currentProgress?.totalPoints ?? 0) ポイント獲得!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }
}
