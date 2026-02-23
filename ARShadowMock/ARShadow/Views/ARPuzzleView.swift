import SwiftUI

struct ARPuzzleView: View {
    var viewModel: ARShadowViewModel
    let stage: PuzzleStage

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // AR Camera background (mock)
            arCameraBackground

            // Shadow projection area
            shadowProjectionArea

            // Light source (draggable)
            lightSourceView

            // Placed objects
            ForEach(viewModel.placedObjects) { object in
                placedObjectView(object)
            }

            // HUD overlay
            VStack {
                hudTop
                Spacer()
                hudBottom
            }
            .padding()

            // Pause overlay
            if viewModel.isPaused {
                pauseOverlay
            }
        }
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            viewModel.tick()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }

    // MARK: - AR Camera Background

    private var arCameraBackground: some View {
        ZStack {
            LinearGradient(
                colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Mock room elements
            VStack {
                Spacer()
                // Floor
                Rectangle()
                    .fill(.brown.opacity(0.15))
                    .frame(height: 200)

                // Wall indication
            }

            // Grid overlay for AR feel
            gridOverlay
        }
    }

    private var gridOverlay: some View {
        Canvas { context, size in
            let gridSpacing: CGFloat = 40
            for x in stride(from: 0, to: size.width, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.05)), lineWidth: 0.5)
            }
            for y in stride(from: 0, to: size.height, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.white.opacity(0.05)), lineWidth: 0.5)
            }
        }
    }

    // MARK: - Shadow Projection

    private var shadowProjectionArea: some View {
        GeometryReader { geometry in
            // Target shape shadow (semi-transparent guide)
            Image(systemName: stage.targetShape.systemImage)
                .font(.system(size: 120))
                .foregroundStyle(.black.opacity(0.15))
                .position(
                    x: geometry.size.width * 0.5,
                    y: geometry.size.height * 0.65
                )

            // Current shadow (mock - based on accuracy)
            if !viewModel.placedObjects.isEmpty {
                Image(systemName: stage.targetShape.systemImage)
                    .font(.system(size: 120))
                    .foregroundStyle(.black.opacity(0.1 + viewModel.currentAccuracy * 0.5))
                    .scaleEffect(0.8 + viewModel.currentAccuracy * 0.2)
                    .rotationEffect(.degrees((1 - viewModel.currentAccuracy) * 15))
                    .position(
                        x: geometry.size.width * 0.5 + (1 - viewModel.currentAccuracy) * 20,
                        y: geometry.size.height * 0.65 + (1 - viewModel.currentAccuracy) * 10
                    )
            }
        }
    }

    // MARK: - Light Source

    private var lightSourceView: some View {
        GeometryReader { geometry in
            let position = CGPoint(
                x: viewModel.lightSource.position.x * geometry.size.width,
                y: viewModel.lightSource.position.y * geometry.size.height
            )

            // Light rays (decorative)
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * (.pi / 4)
                Rectangle()
                    .fill(.yellow.opacity(0.2 * viewModel.lightSource.intensity))
                    .frame(width: 2, height: 30)
                    .rotationEffect(.radians(angle))
                    .position(position)
            }

            // Light source icon
            ZStack {
                Circle()
                    .fill(.yellow.opacity(0.3))
                    .frame(width: 60, height: 60)

                Circle()
                    .fill(.yellow)
                    .frame(width: 40, height: 40)

                Image(systemName: "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let normalizedPosition = CGPoint(
                            x: min(max(value.location.x / geometry.size.width, 0.05), 0.95),
                            y: min(max(value.location.y / geometry.size.height, 0.05), 0.95)
                        )
                        viewModel.moveLightSource(to: normalizedPosition)
                    }
            )
        }
    }

    // MARK: - Placed Objects

    private func placedObjectView(_ object: VirtualObject) -> some View {
        GeometryReader { geometry in
            let position = CGPoint(
                x: object.position.x * geometry.size.width,
                y: object.position.y * geometry.size.height
            )

            ZStack {
                // Object shadow
                Image(systemName: object.shape.systemImage)
                    .font(.system(size: 30 * object.scale))
                    .foregroundStyle(.black.opacity(0.3))
                    .offset(x: 5, y: 8)

                // Object
                Image(systemName: object.shape.systemImage)
                    .font(.system(size: 30 * object.scale))
                    .foregroundStyle(.white.opacity(0.8))
                    .rotationEffect(.radians(object.rotation))
            }
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let normalizedPosition = CGPoint(
                            x: min(max(value.location.x / geometry.size.width, 0.05), 0.95),
                            y: min(max(value.location.y / geometry.size.height, 0.1), 0.9)
                        )
                        viewModel.moveObject(object.id, to: normalizedPosition)
                    }
            )
            .onLongPressGesture {
                viewModel.removeObject(object.id)
            }
        }
    }

    // MARK: - HUD Top

    private var hudTop: some View {
        HStack {
            // Accuracy
            VStack(alignment: .leading, spacing: 4) {
                Text("一致度")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text("\(Int(viewModel.currentAccuracy * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(accuracyColor)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // Target
            VStack(spacing: 4) {
                Image(systemName: stage.targetShape.systemImage)
                    .font(.title3)
                    .foregroundStyle(stage.targetShape.color)
                Text(stage.targetShape.rawValue)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // Timer / Pause
            VStack(alignment: .trailing, spacing: 4) {
                if let remaining = viewModel.remainingTime {
                    Text("残り時間")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(formatTime(remaining))
                        .font(.title2.bold().monospacedDigit())
                        .foregroundStyle(remaining < 10 ? .red : .white)
                } else {
                    Text("経過時間")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(formatTime(viewModel.elapsedTime))
                        .font(.title2.bold().monospacedDigit())
                        .foregroundStyle(.white)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 50)
    }

    // MARK: - HUD Bottom

    private var hudBottom: some View {
        VStack(spacing: 12) {
            // Object count
            HStack {
                Text("オブジェクト: \(viewModel.placedObjects.count)/\(viewModel.currentStageAllowedObjects)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                // Intensity slider
                HStack(spacing: 4) {
                    Image(systemName: "sun.min")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                    Slider(value: Binding(
                        get: { viewModel.lightSource.intensity },
                        set: { viewModel.setLightIntensity($0) }
                    ), in: 0.2...1.0)
                    .frame(width: 100)
                    .tint(.yellow)
                    Image(systemName: "sun.max.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            // Controls
            HStack(spacing: 16) {
                // Pause button
                Button {
                    viewModel.isPaused ? viewModel.resumeGame() : viewModel.pauseGame()
                } label: {
                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                }

                // Object shape picker
                ForEach(ObjectShape.allCases, id: \.self) { shape in
                    Button {
                        viewModel.selectedObjectShape = shape
                    } label: {
                        Image(systemName: shape.systemImage)
                            .font(.title3)
                            .foregroundStyle(viewModel.selectedObjectShape == shape ? .orange : .white.opacity(0.6))
                            .frame(width: 44, height: 44)
                            .background(
                                viewModel.selectedObjectShape == shape
                                    ? .orange.opacity(0.2)
                                    : .white.opacity(0.1),
                                in: Circle()
                            )
                    }
                }

                Spacer()

                // Place object button
                Button {
                    viewModel.placeObject()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(viewModel.canPlaceMoreObjects ? .orange : .gray)
                }
                .disabled(!viewModel.canPlaceMoreObjects)

                // End game button
                Button {
                    viewModel.endGame()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 20)
    }

    // MARK: - Pause Overlay

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)

            VStack(spacing: 24) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)

                Text("一時停止中")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    Button {
                        viewModel.resumeGame()
                    } label: {
                        Label("再開", systemImage: "play.fill")
                            .font(.headline)
                            .frame(width: 200)
                            .padding()
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        viewModel.endGame()
                    } label: {
                        Label("終了", systemImage: "xmark")
                            .font(.headline)
                            .frame(width: 200)
                            .padding()
                            .background(.white.opacity(0.2))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Helpers

    private var accuracyColor: Color {
        if viewModel.currentAccuracy >= 0.8 { return .green }
        if viewModel.currentAccuracy >= 0.5 { return .yellow }
        return .red
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ARPuzzleView(
        viewModel: ARShadowViewModel(),
        stage: PuzzleStage.samples[0]
    )
}
