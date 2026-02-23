import SwiftUI

struct CameraView: View {
    @Bindable var viewModel: CineMagicViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Mock Camera Preview
                cameraPreview

                VStack {
                    // Top Bar
                    topBar

                    Spacer()

                    // AI Composition Advice
                    compositionAdvice

                    // Filter Selector
                    filterSelector

                    // Capture Controls
                    captureControls
                }
            }
            .ignoresSafeArea(edges: .top)
            .task {
                viewModel.startCamera()
            }
            .onDisappear {
                viewModel.stopCamera()
            }
            .sheet(isPresented: $viewModel.showFilterDetail) {
                FilterDetailView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.showCaptureResult) {
                if let capture = viewModel.latestCapture {
                    CaptureResultView(media: capture)
                        .presentationDetents([.medium])
                }
            }
        }
    }

    // MARK: - Camera Preview (Mock)

    private var cameraPreview: some View {
        ZStack {
            // Simulated camera view with filter overlay
            LinearGradient(
                colors: previewGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Filter overlay effect
            viewModel.selectedFilter.color
                .opacity(0.15)

            // Grid overlay
            if viewModel.showCompositionGuide {
                compositionGrid
            }

            // Filter name watermark
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(viewModel.selectedFilter.emoji + " " + viewModel.selectedFilter.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(8)
                }
            }
            .padding(.bottom, 200)
        }
    }

    private var previewGradientColors: [Color] {
        let filter = viewModel.selectedFilter
        switch filter {
        case .nolan: [.black, .blue.opacity(0.4), .gray.opacity(0.3)]
        case .wesAnderson: [.pink.opacity(0.3), .yellow.opacity(0.3), .mint.opacity(0.3)]
        case .ghibli: [.cyan.opacity(0.3), .green.opacity(0.3), .white.opacity(0.5)]
        case .tarantino: [.red.opacity(0.3), .yellow.opacity(0.3), .brown.opacity(0.3)]
        case .lynch: [.black, .indigo.opacity(0.3), .black]
        case .kubrick: [.white.opacity(0.6), .cyan.opacity(0.2), .white.opacity(0.4)]
        case .wonKarWai: [.red.opacity(0.3), .orange.opacity(0.3), .blue.opacity(0.2)]
        case .villeneuve: [.orange.opacity(0.2), .gray.opacity(0.4), .brown.opacity(0.2)]
        }
    }

    private var compositionGrid: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                // Vertical lines
                path.move(to: CGPoint(x: w / 3, y: 0))
                path.addLine(to: CGPoint(x: w / 3, y: h))
                path.move(to: CGPoint(x: w * 2 / 3, y: 0))
                path.addLine(to: CGPoint(x: w * 2 / 3, y: h))
                // Horizontal lines
                path.move(to: CGPoint(x: 0, y: h / 3))
                path.addLine(to: CGPoint(x: w, y: h / 3))
                path.move(to: CGPoint(x: 0, y: h * 2 / 3))
                path.addLine(to: CGPoint(x: w, y: h * 2 / 3))
            }
            .stroke(.white.opacity(0.4), lineWidth: 0.5)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // FPS / Processing
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.0f FPS", viewModel.currentFPS))
                    .font(.caption2)
                    .fontWeight(.bold)

                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.processingLoad > 0.6 ? .orange : .green)
                        .frame(width: 6, height: 6)
                    Text(String(format: "GPU %.0f%%", viewModel.processingLoad * 100))
                        .font(.caption2)
                }
            }
            .foregroundStyle(.white)
            .padding(8)
            .background(.black.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer()

            // Grid toggle
            Button {
                viewModel.showCompositionGuide.toggle()
            } label: {
                Image(systemName: viewModel.showCompositionGuide ? "grid" : "grid.circle")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.5))
                    .clipShape(Circle())
            }

            // Filter detail
            Button {
                viewModel.showFilterDetail = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 60)
    }

    // MARK: - Composition Advice

    private var compositionAdvice: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.currentAdvice.icon)
                .foregroundStyle(.yellow)
            Text(viewModel.currentAdvice.suggestion)
                .font(.caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.black.opacity(0.6))
        .clipShape(Capsule())
        .padding(.bottom, 8)
    }

    // MARK: - Filter Selector

    private var filterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CineFilter.allCases) { filter in
                    Button {
                        viewModel.selectFilter(filter)
                    } label: {
                        VStack(spacing: 4) {
                            Text(filter.emoji)
                                .font(.title2)

                            Text(filter.rawValue)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .frame(width: 64, height: 64)
                        .background(
                            viewModel.selectedFilter == filter
                                ? filter.color.opacity(0.3)
                                : .black.opacity(0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    viewModel.selectedFilter == filter
                                        ? filter.color
                                        : .clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .foregroundStyle(.white)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Capture Controls

    private var captureControls: some View {
        HStack(alignment: .center, spacing: 40) {
            // Mode switch
            Picker("モード", selection: $viewModel.captureMode) {
                ForEach(CaptureMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 140)

            // Capture button
            Button {
                if viewModel.captureMode == .photo {
                    viewModel.capturePhoto()
                } else {
                    viewModel.toggleRecording()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                        .frame(width: 72, height: 72)

                    if viewModel.captureMode == .photo {
                        Circle()
                            .fill(.white)
                            .frame(width: 60, height: 60)
                    } else {
                        if viewModel.isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.red)
                                .frame(width: 28, height: 28)
                        } else {
                            Circle()
                                .fill(.red)
                                .frame(width: 60, height: 60)
                        }
                    }
                }
            }

            // Recording duration or gallery shortcut
            if viewModel.isRecording {
                Text(viewModel.formattedRecordingDuration)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .frame(width: 140)
            } else {
                Button {
                    viewModel.selectedTab = .gallery
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "photo.stack")
                            .font(.title3)
                        Text("\(viewModel.capturedMedia.count)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 140)
                }
            }
        }
        .padding()
        .background(.black.opacity(0.7))
    }
}

#Preview {
    CameraView(viewModel: CineMagicViewModel())
}
