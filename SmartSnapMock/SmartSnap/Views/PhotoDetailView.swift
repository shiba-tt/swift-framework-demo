import SwiftUI

struct PhotoDetailView: View {
    @Bindable var viewModel: SmartSnapViewModel
    let photo: Photo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    photoPreview
                    captionSection
                    detectedObjectsSection
                    metadataSection
                }
                .padding()
            }
            .navigationTitle(photo.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - Photo Preview

    private var photoPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.85))
                .frame(height: 220)

            VStack(spacing: 12) {
                Image(systemName: photo.systemImageName)
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.6))

                if let location = photo.location {
                    Label(location.name, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }

    // MARK: - Caption Section

    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AI キャプション", systemImage: "text.bubble")
                    .font(.headline)
                Spacer()
            }

            if let caption = photo.caption {
                Text(caption)
                    .font(.subheadline)
                    .lineSpacing(3)
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            }

            // タグ
            if !photo.tags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("タグ")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(photo.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.orange.opacity(0.1), in: Capsule())
                        }
                    }
                }
            }

            // 再生成ボタン
            Button {
                Task {
                    await viewModel.generateCaption(for: photo)
                }
            } label: {
                if viewModel.isAnalyzing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text(viewModel.analysisProgress ?? "分析中...")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                } else {
                    Label("AI でキャプションを再生成", systemImage: "wand.and.stars")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(viewModel.isAnalyzing)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Detected Objects Section

    private var detectedObjectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Vision 検出結果", systemImage: "eye")
                .font(.headline)

            // 検出オブジェクト
            if !photo.detectedObjects.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("オブジェクト認識")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(photo.detectedObjects, id: \.self) { obj in
                            HStack(spacing: 4) {
                                Image(systemName: "cube")
                                    .font(.caption2)
                                Text(obj)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(.blue.opacity(0.1), in: Capsule())
                        }
                    }
                }
            }

            // OCR テキスト
            if let text = photo.detectedText {
                VStack(alignment: .leading, spacing: 6) {
                    Text("テキスト認識 (OCR)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(text)
                        .font(.subheadline)
                        .monospacedDigit()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("メタデータ")
                .font(.headline)

            VStack(spacing: 8) {
                metadataRow(icon: "doc", label: "ファイル名", value: photo.fileName)
                metadataRow(icon: "calendar", label: "撮影日時", value: photo.formattedDate)
                if let location = photo.location {
                    metadataRow(icon: "mappin", label: "場所", value: location.name)
                    metadataRow(icon: "location", label: "座標", value: String(format: "%.4f, %.4f", location.latitude, location.longitude))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

#Preview {
    PhotoDetailView(
        viewModel: SmartSnapViewModel(),
        photo: Photo.samplePhotos[0]
    )
}
