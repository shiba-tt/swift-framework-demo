import SwiftUI

struct CanvasView: View {
    @Bindable var viewModel: SpaceCanvasViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isSessionActive {
                    ActiveCanvasView(viewModel: viewModel)
                } else {
                    StartSessionView(viewModel: viewModel)
                }
            }
            .navigationTitle("SpaceCanvas")
            .toolbar {
                if viewModel.isSessionActive {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                viewModel.showSaveDialog = true
                            } label: {
                                Label("作品を保存", systemImage: "square.and.arrow.down")
                            }
                            Button {
                                viewModel.undoLastStroke()
                            } label: {
                                Label("元に戻す", systemImage: "arrow.uturn.backward")
                            }
                            Button(role: .destructive) {
                                viewModel.clearCanvas()
                            } label: {
                                Label("全消去", systemImage: "trash")
                            }
                            Divider()
                            Button(role: .destructive) {
                                viewModel.endSession()
                            } label: {
                                Label("セッション終了", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("作品を保存", isPresented: $viewModel.showSaveDialog) {
                TextField("タイトル", text: $viewModel.saveTitle)
                Button("保存") { viewModel.saveArtwork() }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("作品にタイトルを付けて保存します")
            }
        }
    }
}

// MARK: - Start Session View

private struct StartSessionView: View {
    @Bindable var viewModel: SpaceCanvasViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                Image(systemName: "scribble.variable")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 8) {
                    Text("空間お絵描き AR")
                        .font(.title.bold())
                    Text("複数の iPhone で AR 空間に\n3D のお絵描きをしよう")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    viewModel.startSession()
                } label: {
                    Label("セッションを開始", systemImage: "arkit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.cyan)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)

                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        FeatureBadge(
                            icon: "hand.draw.fill", title: "3D 描画",
                            subtitle: "空中にお絵描き"
                        )
                        FeatureBadge(
                            icon: "person.3.fill", title: "マルチプレイ",
                            subtitle: "複数人で同時に"
                        )
                    }
                    HStack(spacing: 20) {
                        FeatureBadge(
                            icon: "location.fill", title: "UWB 追跡",
                            subtitle: "cm 精度の位置"
                        )
                        FeatureBadge(
                            icon: "cube.fill", title: "USDZ 書出",
                            subtitle: "3D 作品を共有"
                        )
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding()
        }
    }
}

private struct FeatureBadge: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.cyan)
                .frame(width: 44, height: 44)
                .background(.cyan.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Active Canvas View

private struct ActiveCanvasView: View {
    @Bindable var viewModel: SpaceCanvasViewModel

    var body: some View {
        VStack(spacing: 0) {
            // AR Preview (mock)
            ARPreviewMock(viewModel: viewModel)

            // Toolbar
            DrawingToolbar(viewModel: viewModel)
        }
    }
}

// MARK: - AR Preview Mock

private struct ARPreviewMock: View {
    @Bindable var viewModel: SpaceCanvasViewModel

    var body: some View {
        ZStack {
            // Background simulating camera
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemGray6),
                            Color(.systemGray4),
                            Color(.systemGray5),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Grid overlay
            GridOverlay()

            // Stroke visualization
            Canvas { context, size in
                for stroke in viewModel.strokes {
                    drawStroke(stroke, in: &context, size: size)
                }
                if let current = viewModel.currentStroke {
                    drawStroke(current, in: &context, size: size)
                }
            }

            // Session info overlay
            VStack {
                HStack {
                    // Session badge
                    HStack(spacing: 6) {
                        Circle().fill(.red).frame(width: 8, height: 8)
                        Text("AR セッション")
                            .font(.caption2.bold())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                    Spacer()

                    // Stats
                    HStack(spacing: 12) {
                        Label(viewModel.sessionDurationText, systemImage: "clock")
                        Label("\(viewModel.totalStrokes)", systemImage: "scribble")
                        Label("\(viewModel.connectedArtists)", systemImage: "person.2")
                    }
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding()

                Spacer()

                // Drawing indicator
                if viewModel.isDrawing {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(viewModel.selectedColor.color)
                            .frame(width: 10, height: 10)
                        Text("描画中... \(viewModel.currentStrokePointCount)pts")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 8)
                }
            }

            // Artist position indicators
            ForEach(viewModel.artists.filter({ $0.name != "あなた" })) { artist in
                ArtistIndicator(artist: artist)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    private func drawStroke(
        _ stroke: Stroke, in context: inout GraphicsContext, size: CGSize
    ) {
        guard stroke.points.count >= 2 else { return }
        var path = Path()
        for (i, point) in stroke.points.enumerated() {
            let x = CGFloat((point.position.x + 0.5)) * size.width
            let y = CGFloat((1.0 - (point.position.y + 0.3))) * size.height
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.stroke(
            path,
            with: .color(stroke.color.color),
            lineWidth: CGFloat(stroke.thickness)
        )
    }
}

private struct GridOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let cols = 8
            let rows = 12
            Path { path in
                for i in 1..<cols {
                    let x = geo.size.width / CGFloat(cols) * CGFloat(i)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                for i in 1..<rows {
                    let y = geo.size.height / CGFloat(rows) * CGFloat(i)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        }
    }
}

private struct ArtistIndicator: View {
    let artist: Artist

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "iphone")
                .font(.title3)
                .foregroundStyle(artist.assignedColor.color)
            Text(artist.name)
                .font(.caption2.bold())
                .foregroundStyle(.white)
            Text(artist.distanceText)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(6)
        .background(.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .offset(
            x: CGFloat(artist.direction?.x ?? 0) * 100,
            y: CGFloat(artist.direction?.y ?? 0) * 60
        )
    }
}

// MARK: - Drawing Toolbar

private struct DrawingToolbar: View {
    @Bindable var viewModel: SpaceCanvasViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Color picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(StrokeColor.allCases) { color in
                        Button {
                            viewModel.selectedColor = color
                        } label: {
                            Circle()
                                .fill(color.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            viewModel.selectedColor == color
                                                ? Color.white : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .shadow(
                                    color: viewModel.selectedColor == color
                                        ? color.color.opacity(0.5) : .clear,
                                    radius: 4
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Thickness picker
            HStack(spacing: 16) {
                ForEach(BrushThickness.allCases) { thickness in
                    Button {
                        viewModel.selectedThickness = thickness
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(
                                    viewModel.selectedThickness == thickness
                                        ? viewModel.selectedColor.color
                                        : Color(.systemGray4)
                                )
                                .frame(
                                    width: CGFloat(thickness.rawValue * 3 + 8),
                                    height: CGFloat(thickness.rawValue * 3 + 8)
                                )
                            Text(thickness.displayName)
                                .font(.system(size: 9))
                                .foregroundStyle(
                                    viewModel.selectedThickness == thickness
                                        ? .primary : .secondary
                                )
                        }
                    }
                }

                Spacer()

                // Undo
                Button {
                    viewModel.undoLastStroke()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .disabled(viewModel.strokes.isEmpty)
            }
            .padding(.horizontal)

            // Draw button
            Button {
                viewModel.toggleDrawing()
            } label: {
                HStack {
                    Image(
                        systemName: viewModel.isDrawing
                            ? "stop.circle.fill" : "pencil.tip.crop.circle.fill"
                    )
                    .font(.title2)
                    Text(viewModel.isDrawing ? "描画を停止" : "描画を開始")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.isDrawing
                        ? AnyShapeStyle(.red)
                        : AnyShapeStyle(viewModel.selectedColor.color)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
