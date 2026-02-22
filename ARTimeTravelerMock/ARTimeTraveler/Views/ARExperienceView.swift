import SwiftUI

struct ARExperienceView: View {
    @Bindable var viewModel: ARTimeTravelerViewModel

    var body: some View {
        ZStack {
            // AR Camera Placeholder
            cameraPlaceholder

            VStack {
                topOverlay

                Spacer()

                bottomControls
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Camera Placeholder

    private var cameraPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [.black, Color(.systemGray5)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.3))

                if let snapshot = viewModel.currentSnapshot {
                    VStack(spacing: 4) {
                        Text("AR オーバーレイ表示中")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))

                        Text("3D Model: \(snapshot.modelName)")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                // 仮想3Dモデルプレースホルダー
                if let era = viewModel.selectedEra {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(era.color.opacity(0.6), lineWidth: 2)
                        .fill(era.color.opacity(0.08))
                        .frame(width: 250, height: 180)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "building.columns")
                                    .font(.system(size: 40))
                                    .foregroundStyle(era.color)
                                Text(viewModel.currentSnapshot?.title ?? "")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                        }
                }
            }
        }
    }

    // MARK: - Top Overlay

    private var topOverlay: some View {
        VStack(spacing: 8) {
            HStack {
                if let spot = viewModel.selectedSpot {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(spot.name)
                            .font(.headline)
                        if let era = viewModel.selectedEra {
                            Text(era.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(era.color.opacity(0.8), in: .capsule)
                        }
                    }
                }

                Spacer()

                Button {
                    viewModel.recordVisit()
                    viewModel.stopAR()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            .foregroundStyle(.white)
            .padding()
            .background(.ultraThinMaterial.opacity(0.8))
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Audio Guide
            audioGuideBar

            // Time Slider
            timeSlider

            // Era Quick Select
            eraQuickSelect
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var audioGuideBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.toggleAudioGuide()
            } label: {
                Image(systemName: viewModel.isAudioPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("音声ガイド")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ProgressView(value: viewModel.audioProgress)
                    .tint(.indigo)
            }

            if let snapshot = viewModel.currentSnapshot {
                Text(snapshot.durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timeSlider: some View {
        VStack(spacing: 4) {
            HStack {
                Text("年代スライダー")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(viewModel.sliderYear))年")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.indigo)
            }

            Slider(
                value: Binding(
                    get: { viewModel.sliderYear },
                    set: { viewModel.updateSliderYear($0) }
                ),
                in: viewModel.yearRangeForSlider,
                step: 1
            )
            .tint(.indigo)
        }
    }

    private var eraQuickSelect: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.availableEras) { era in
                    let isSelected = viewModel.selectedEra?.id == era.id
                    Button {
                        viewModel.selectEra(era)
                    } label: {
                        Text(era.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                isSelected ? era.color : Color(.systemGray5),
                                in: .capsule
                            )
                            .foregroundStyle(isSelected ? .white : .primary)
                    }
                }
            }
        }
    }
}

#Preview {
    let vm = ARTimeTravelerViewModel()
    vm.selectSpot(SpotManager.shared.spots.first!)
    vm.startAR()
    return ARExperienceView(viewModel: vm)
}
