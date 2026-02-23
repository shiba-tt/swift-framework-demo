import SwiftUI

// MARK: - ARTimeView

struct ARTimeView: View {
    var viewModel: ARTimeMachineViewModel
    let spot: HistoricalSpot

    var body: some View {
        NavigationStack {
            ZStack {
                arCameraBackground
                overlayUI
            }
            .navigationTitle(spot.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.stopAR()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }

    // MARK: - AR Camera Background (Mock)

    private var arCameraBackground: some View {
        GeometryReader { geo in
            ZStack {
                // カメラフィード（モック）
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // メッシュオーバーレイ（モック）
                if viewModel.isScanning {
                    scanningOverlay(size: geo.size)
                } else {
                    arContentOverlay(size: geo.size)
                }
            }
        }
    }

    private var gradientColors: [Color] {
        guard let era = viewModel.currentEra else {
            return [.gray.opacity(0.3), .gray.opacity(0.1)]
        }
        return [era.color.opacity(0.3), era.color.opacity(0.1)]
    }

    private func scanningOverlay(size: CGSize) -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("スキャン中...")
                .font(.headline)
            Text("カメラをゆっくり動かしてください")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let mesh = viewModel.sceneMeshResult {
                Text(mesh.summary)
                    .font(.caption2)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial.opacity(0.7))
    }

    private func arContentOverlay(size: CGSize) -> some View {
        VStack {
            Spacer()

            // AR建物モック表示
            if let period = viewModel.currentTimePeriod {
                buildingVisualization(period: period, size: size)
            }

            Spacer()
        }
    }

    private func buildingVisualization(period: TimePeriod, size: CGSize) -> some View {
        VStack(spacing: 8) {
            Image(systemName: spot.category.systemImage)
                .font(.system(size: 80))
                .foregroundStyle(period.era.color.opacity(viewModel.overlayOpacity))
                .shadow(color: period.era.color.opacity(0.5), radius: 20)

            Text(period.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .shadow(radius: 4)

            Text(period.yearText)
                .font(.headline)
                .foregroundStyle(period.era.color)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.5))
        )
    }

    // MARK: - Overlay UI

    private var overlayUI: some View {
        VStack {
            topInfoBar
            Spacer()
            bottomControls
        }
        .padding()
    }

    private var topInfoBar: some View {
        HStack {
            if let facade = viewModel.facadeResult {
                Label("認識: \(facade.matchedLandmark)", systemImage: "eye.fill")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: viewModel.overlayMode.systemImage)
                Text(viewModel.overlayMode.rawValue)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            timeSlider
            actionButtons
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var timeSlider: some View {
        VStack(spacing: 8) {
            HStack {
                Text("タイムスライダー")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let period = viewModel.currentTimePeriod {
                    Label(period.era.rawValue, systemImage: period.era.systemImage)
                        .font(.caption)
                        .foregroundStyle(period.era.color)
                }
            }

            Slider(
                value: $viewModel.sliderYear,
                in: viewModel.minYear...viewModel.maxYear,
                step: 1
            ) {
                Text("年")
            } onEditingChanged: { editing in
                if !editing {
                    viewModel.snapToNearestPeriod()
                }
            }
            .tint(.indigo)

            HStack {
                Text(Int(viewModel.minYear).description + "年")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Int(viewModel.sliderYear).description + "年")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                Spacer()
                Text(Int(viewModel.maxYear).description + "年")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // 年代ジャンプボタン
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.nearestYears, id: \.self) { year in
                        Button {
                            viewModel.jumpToYear(year)
                        } label: {
                            Text("\(year)年")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Int(viewModel.sliderYear) == year
                                        ? Color.indigo
                                        : Color(.systemGray5)
                                )
                                .foregroundStyle(
                                    Int(viewModel.sliderYear) == year
                                        ? .white
                                        : .primary
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.captureARPhoto()
            } label: {
                Label("AR写真", systemImage: "camera.fill")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.indigo)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            Menu {
                ForEach(AROverlayMode.allCases, id: \.self) { mode in
                    Button {
                        viewModel.setOverlayMode(mode)
                    } label: {
                        Label(mode.rawValue, systemImage: mode.systemImage)
                    }
                }
            } label: {
                Label("表示モード", systemImage: "slider.horizontal.3")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
            }

            Spacer()

            VStack(spacing: 2) {
                Text("透明度")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Slider(value: $viewModel.overlayOpacity, in: 0...1)
                    .frame(width: 80)
                    .tint(.indigo)
            }
        }
    }
}

#Preview {
    let vm = ARTimeMachineViewModel()
    vm.selectedSpot = HistoricalSpot.samples[0]
    vm.isARActive = true
    vm.selectedTimePeriod = HistoricalSpot.samples[0].timePeriods[0]
    return ARTimeView(viewModel: vm, spot: HistoricalSpot.samples[0])
}
