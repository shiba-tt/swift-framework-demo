import SwiftUI

struct ARExhibitionView: View {
    @Bindable var viewModel: ARMuseumViewModel
    let exhibition: Exhibition
    @State private var selectedArtworkIndex = 0
    @State private var showingControls = true

    private var exhibitionArtworks: [Artwork] {
        viewModel.artworks(for: exhibition)
    }

    var body: some View {
        ZStack {
            arSimulationView
            controlOverlay
        }
        .ignoresSafeArea()
        .onTapGesture {
            withAnimation { showingControls.toggle() }
        }
    }

    // MARK: - AR Simulation

    @ViewBuilder
    private var arSimulationView: some View {
        ZStack {
            // 部屋の背景
            exhibition.theme.backgroundColor
                .ignoresSafeArea()

            // 壁面シミュレーション
            VStack {
                // 天井の照明
                HStack(spacing: 40) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(.yellow.opacity(0.6))
                            .frame(width: 15, height: 15)
                            .shadow(color: .yellow.opacity(0.5), radius: 20)
                    }
                }
                .padding(.top, 60)

                Spacer()

                // 作品展示エリア
                if exhibitionArtworks.isEmpty {
                    Text("作品が展示されていません")
                        .foregroundStyle(exhibition.theme.textColor.opacity(0.5))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(Array(exhibitionArtworks.enumerated()), id: \.element.id) { index, artwork in
                                artworkInAR(artwork, isSelected: index == selectedArtworkIndex)
                                    .onTapGesture {
                                        selectedArtworkIndex = index
                                    }
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }

                Spacer()

                // 床の順路表示
                HStack(spacing: 4) {
                    ForEach(0..<20, id: \.self) { i in
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: i % 3 == 2 ? 4 : 12, height: 2)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .padding(.bottom, 100)
            }
        }
    }

    @ViewBuilder
    private func artworkInAR(_ artwork: Artwork, isSelected: Bool) -> some View {
        VStack(spacing: 12) {
            // スポットライト効果
            Circle()
                .fill(.yellow.opacity(isSelected ? 0.4 : 0.15))
                .frame(width: 8, height: 8)
                .shadow(color: .yellow.opacity(isSelected ? 0.6 : 0.2), radius: isSelected ? 30 : 10)

            // 作品フレーム
            VStack(spacing: 0) {
                if artwork.displayType == .wallFrame || artwork.displayType == .showcase {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(artwork.thumbnailColor.gradient)
                        .frame(width: 120, height: 150)
                        .overlay {
                            Image(systemName: artwork.category.systemImage)
                                .font(.largeTitle)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(viewModel.currentFrameStyle.borderWidth)
                        .background(viewModel.currentFrameStyle.borderColor)
                        .shadow(color: .black.opacity(isSelected ? 0.4 : 0.2), radius: isSelected ? 12 : 4, y: 4)
                } else {
                    // 台座・浮遊展示
                    RoundedRectangle(cornerRadius: 12)
                        .fill(artwork.thumbnailColor.gradient)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Image(systemName: artwork.category.systemImage)
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .rotation3DEffect(.degrees(isSelected ? 15 : 0), axis: (x: 0, y: 1, z: 0))
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 6)

                    if artwork.displayType == .pedestal {
                        // 台座
                        Trapezoid()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 80, height: 20)
                    }
                }
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(duration: 0.3), value: isSelected)

            // キャプション
            if isSelected {
                VStack(spacing: 2) {
                    Text(artwork.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(exhibition.theme.textColor)
                    Text(artwork.artist)
                        .font(.caption2)
                        .foregroundStyle(exhibition.theme.textColor.opacity(0.7))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 6))
                .transition(.opacity)
            }
        }
    }

    // MARK: - Controls

    @ViewBuilder
    private var controlOverlay: some View {
        if showingControls {
            VStack {
                // トップバー
                HStack {
                    Button {
                        viewModel.exitAR()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                    }

                    Spacer()

                    Text(exhibition.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)

                    Spacer()

                    Button {} label: {
                        Image(systemName: "camera.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                    }
                }
                .padding()
                .padding(.top, 40)

                Spacer()

                // ボトムコントロール
                if !exhibitionArtworks.isEmpty && selectedArtworkIndex < exhibitionArtworks.count {
                    let artwork = exhibitionArtworks[selectedArtworkIndex]
                    VStack(spacing: 12) {
                        Text("\(selectedArtworkIndex + 1) / \(exhibitionArtworks.count)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))

                        HStack(spacing: 20) {
                            controlButton(icon: "light.overhead.left", label: "照明") {
                                viewModel.showingLightEditor = true
                            }
                            controlButton(icon: "rotate.3d", label: "回転") {}
                            controlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", label: "移動") {}
                            controlButton(icon: "info.circle", label: "詳細") {
                                viewModel.selectArtwork(artwork)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                    .padding()
                }
            }
            .transition(.opacity)
        }
    }

    @ViewBuilder
    private func controlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(.white)
            .frame(width: 55)
        }
    }
}

// MARK: - Trapezoid Shape

struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset: CGFloat = rect.width * 0.15
        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width - inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ARExhibitionView(
        viewModel: ARMuseumViewModel(),
        exhibition: Exhibition.samples[0]
    )
}
