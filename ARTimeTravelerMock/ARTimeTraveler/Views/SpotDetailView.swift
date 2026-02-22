import SwiftUI

struct SpotDetailView: View {
    let spot: HistoricalSpot
    @Bindable var viewModel: ARTimeTravelerViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    mapPlaceholder

                    VStack(alignment: .leading, spacing: 16) {
                        spotInfo

                        eraSelector

                        snapshotDetail

                        startARButton
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(spot.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        viewModel.showingSpotDetail = false
                    }
                }
            }
        }
    }

    // MARK: - Map Placeholder

    private var mapPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.indigo.opacity(0.3), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)

            VStack(spacing: 6) {
                Image(systemName: "map")
                    .font(.system(size: 36))
                    .foregroundStyle(.indigo)
                Text("位置: \(String(format: "%.4f", spot.latitude)), \(String(format: "%.4f", spot.longitude))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("NFC: \(spot.nfcTagID)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Spot Info

    private var spotInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(spot.category.rawValue, systemImage: spot.category.icon)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.systemGray5), in: .capsule)

                Spacer()

                Text("\(spot.snapshots.count) 時代を体験")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(spot.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Era Selector

    private var eraSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("時代を選択")
                .font(.headline)

            VStack(spacing: 4) {
                Slider(
                    value: Binding(
                        get: { viewModel.sliderYear },
                        set: { viewModel.updateSliderYear($0) }
                    ),
                    in: viewModel.yearRangeForSlider,
                    step: 1
                )
                .tint(.indigo)

                HStack {
                    Text("\(Int(viewModel.yearRangeForSlider.lowerBound))年")
                    Spacer()
                    Text("\(Int(viewModel.sliderYear))年")
                        .fontWeight(.bold)
                        .foregroundStyle(.indigo)
                    Spacer()
                    Text("\(Int(viewModel.yearRangeForSlider.upperBound))年")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(spot.snapshots) { snapshot in
                        let isSelected = viewModel.selectedEra?.id == snapshot.era.id
                        Button {
                            viewModel.selectEra(snapshot.era)
                        } label: {
                            VStack(spacing: 4) {
                                Text(snapshot.era.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(snapshot.era.yearRange)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ? snapshot.era.color : Color(.systemGray5),
                                in: .rect(cornerRadius: 8)
                            )
                            .foregroundStyle(isSelected ? .white : .primary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Snapshot Detail

    @ViewBuilder
    private var snapshotDetail: some View {
        if let snapshot = viewModel.currentSnapshot {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(snapshot.era.color)
                        .frame(width: 10, height: 10)
                    Text(snapshot.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(snapshot.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label("3D: \(snapshot.modelName)", systemImage: "cube")
                    Label("音声: \(snapshot.durationText)", systemImage: "speaker.wave.2")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.systemGray6), in: .rect(cornerRadius: 12))
        }
    }

    // MARK: - Start AR

    private var startARButton: some View {
        Button {
            viewModel.startAR()
            viewModel.showingSpotDetail = false
        } label: {
            Label("AR体験を開始", systemImage: "camera.viewfinder")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.indigo.gradient, in: .rect(cornerRadius: 12))
                .foregroundStyle(.white)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    let spot = SpotManager.shared.spots.first!
    SpotDetailView(spot: spot, viewModel: ARTimeTravelerViewModel())
}
