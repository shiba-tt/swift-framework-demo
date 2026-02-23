import SwiftUI

struct ArtworkDetailView: View {
    @Bindable var viewModel: ARMuseumViewModel
    let artwork: Artwork
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFrameStyle: FrameStyle = .classic

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    artworkPreview
                    artworkInfo
                    frameStylePicker
                    lightingSection
                    metadataSection
                }
                .padding()
            }
            .navigationTitle(artwork.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - Preview

    @ViewBuilder
    private var artworkPreview: some View {
        VStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(artwork.thumbnailColor.gradient)
                .frame(height: 250)
                .overlay {
                    VStack {
                        Image(systemName: artwork.category.systemImage)
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.8))
                        if artwork.displayType == .pedestal || artwork.displayType == .floating {
                            Text("3D モデル")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.top, 4)
                        }
                    }
                }
                .padding(selectedFrameStyle.borderWidth)
                .background(selectedFrameStyle.borderColor)
                .clipShape(.rect(cornerRadius: 6))
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

            Text(selectedFrameStyle.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Info

    @ViewBuilder
    private var artworkInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(artwork.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(artwork.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(artwork.category.color.opacity(0.15), in: .capsule)
                    .foregroundStyle(artwork.category.color)
            }

            HStack {
                Image(systemName: "person")
                Text(artwork.artist)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "calendar")
                Text(artwork.formattedDate)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            if !artwork.description.isEmpty {
                Text(artwork.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    // MARK: - Frame Style

    @ViewBuilder
    private var frameStylePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("額縁スタイル", systemImage: "photo.artframe")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FrameStyle.allCases, id: \.self) { style in
                        Button {
                            selectedFrameStyle = style
                        } label: {
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(artwork.thumbnailColor.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                    .padding(style.borderWidth * 0.5)
                                    .background(style.borderColor)
                                    .clipShape(.rect(cornerRadius: 4))

                                Text(style.rawValue)
                                    .font(.caption2)
                            }
                            .padding(8)
                            .background(
                                selectedFrameStyle == style ? .indigo.opacity(0.1) : .clear,
                                in: .rect(cornerRadius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedFrameStyle == style ? .indigo : .clear, lineWidth: 2)
                            )
                        }
                        .tint(.primary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    // MARK: - Lighting

    @ViewBuilder
    private var lightingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("照明設定", systemImage: "light.overhead.left")
                .font(.headline)

            if let light = viewModel.spotLight(for: artwork.id) {
                VStack(spacing: 8) {
                    HStack {
                        Text("強度")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(light.intensity * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: light.intensity)
                        .tint(.yellow)

                    HStack {
                        Text("色温度")
                            .font(.subheadline)
                        Spacer()
                        Text(light.temperatureLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: light.temperature, total: 6500)
                        .tint(.orange)
                }
            } else {
                Button {
                    viewModel.addSpotLight(for: artwork.id)
                } label: {
                    Label("スポットライトを追加", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    // MARK: - Metadata

    @ViewBuilder
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("詳細情報", systemImage: "info.circle")
                .font(.headline)

            Group {
                metadataRow(label: "展示方法", value: artwork.displayType.rawValue)
                metadataRow(label: "スケール", value: String(format: "%.1fx", artwork.scaleMultiplier))
                if let modelFile = artwork.modelFileName {
                    metadataRow(label: "3Dモデル", value: modelFile)
                }
                metadataRow(label: "ID", value: artwork.id.uuidString.prefix(8).description)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    @ViewBuilder
    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    ArtworkDetailView(
        viewModel: ARMuseumViewModel(),
        artwork: Artwork.samples[0]
    )
}
