import SwiftUI

/// ジェネラティブアート表示画面
struct ArtView: View {
    let viewModel: GridPulseViewModel

    @State private var timer: Timer?

    var body: some View {
        ZStack {
            // 背景グラデーション
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // アートキャンバス
                artCanvas
                    .frame(maxHeight: .infinity)

                // 情報オーバーレイ
                infoOverlay
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
                Task { @MainActor in
                    viewModel.updateAnimation()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        let level = viewModel.currentLevel
        let colors: [Color] = switch level {
        case .veryClean: [.green.opacity(0.1), .mint.opacity(0.2), .black]
        case .clean: [.mint.opacity(0.1), .teal.opacity(0.15), .black]
        case .moderate: [.yellow.opacity(0.1), .orange.opacity(0.1), Color(.systemBackground)]
        case .dirty: [.red.opacity(0.1), .gray.opacity(0.2), Color(.systemBackground)]
        }

        return LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Art Canvas

    private var artCanvas: some View {
        GeometryReader { geometry in
            ZStack {
                switch viewModel.selectedTheme {
                case .wave:
                    waveArt(in: geometry.size)
                case .particle:
                    particleArt(in: geometry.size)
                case .gradient:
                    gradientArt(in: geometry.size)
                }
            }
        }
    }

    // MARK: - Wave Art

    private func waveArt(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let midY = canvasSize.height / 2

            for (index, wave) in viewModel.waves.enumerated() {
                var path = Path()
                let steps = Int(canvasSize.width)

                for x in 0...steps {
                    let xPos = Double(x)
                    let normalizedX = xPos / canvasSize.width
                    let yOffset = wave.amplitude * sin(
                        normalizedX * wave.frequency * .pi * 2
                        + viewModel.animationPhase * (1 + Double(index) * 0.3)
                        + wave.phase
                    )

                    let y = midY + yOffset + Double(index) * 20

                    if x == 0 {
                        path.move(to: CGPoint(x: xPos, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: xPos, y: y))
                    }
                }

                context.stroke(
                    path,
                    with: .color(viewModel.currentState?.color.opacity(0.6 - Double(index) * 0.15) ?? .green),
                    lineWidth: 3 - Double(index) * 0.5
                )
            }
        }
        .overlay {
            // パーティクルも重ねて表示
            ForEach(viewModel.particles) { particle in
                Image(systemName: particle.type.systemImage)
                    .font(.system(size: particle.size))
                    .foregroundStyle(particle.color)
                    .opacity(particle.opacity)
                    .position(
                        x: particle.x * size.width,
                        y: particle.y * size.height
                    )
            }
        }
    }

    // MARK: - Particle Art

    private func particleArt(in size: CGSize) -> some View {
        ZStack {
            ForEach(viewModel.particles) { particle in
                Image(systemName: particle.type.systemImage)
                    .font(.system(size: particle.size))
                    .foregroundStyle(particle.color)
                    .opacity(particle.opacity)
                    .position(
                        x: particle.x * size.width,
                        y: particle.y * size.height
                    )
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: particle.opacity
                    )
            }
        }
    }

    // MARK: - Gradient Art

    private func gradientArt(in size: CGSize) -> some View {
        let cleanness = viewModel.currentState?.cleanEnergyFraction ?? 0.5

        return ZStack {
            // 放射状グラデーション
            RadialGradient(
                colors: [
                    viewModel.currentState?.color.opacity(0.8) ?? .green,
                    viewModel.currentState?.color.opacity(0.3) ?? .green,
                    .clear,
                ],
                center: .center,
                startRadius: 20,
                endRadius: size.width * 0.6 * cleanness
            )
            .scaleEffect(1 + 0.1 * sin(viewModel.animationPhase))
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: viewModel.animationPhase)

            // パーティクルオーバーレイ
            ForEach(viewModel.particles.prefix(15)) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity * 0.5))
                    .frame(width: particle.size * 2, height: particle.size * 2)
                    .position(
                        x: particle.x * size.width,
                        y: particle.y * size.height
                    )
                    .blur(radius: particle.size * 0.5)
            }
        }
    }

    // MARK: - Info Overlay

    private var infoOverlay: some View {
        VStack(spacing: 16) {
            // クリーン度表示
            VStack(spacing: 4) {
                Text(viewModel.currentCleanText)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.currentState?.color ?? .green)

                Text("クリーン")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("「\(viewModel.currentThemeName)」")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // テーマ切り替え
            HStack(spacing: 16) {
                ForEach(ArtTheme.allCases, id: \.self) { theme in
                    Button {
                        viewModel.selectedTheme = theme
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: theme.icon)
                                .font(.title3)
                            Text(theme.rawValue)
                                .font(.caption2)
                        }
                        .foregroundStyle(
                            viewModel.selectedTheme == theme ? .primary : .secondary
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedTheme == theme
                                ? viewModel.currentState?.color.opacity(0.2) ?? .green.opacity(0.2)
                                : .clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            // 24時間タイムライン（ミニ）
            miniTimeline
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var miniTimeline: some View {
        HStack(spacing: 2) {
            ForEach(viewModel.gridStates) { state in
                RoundedRectangle(cornerRadius: 2)
                    .fill(state.color)
                    .frame(height: 16)
                    .opacity(isCurrent(state) ? 1.0 : 0.6)
                    .overlay {
                        if isCurrent(state) {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(.white, lineWidth: 1)
                        }
                    }
            }
        }
        .frame(height: 16)
    }

    private func isCurrent(_ state: GridState) -> Bool {
        state.id == viewModel.currentState?.id
    }
}
