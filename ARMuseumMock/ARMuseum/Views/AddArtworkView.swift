import SwiftUI

struct AddArtworkView: View {
    @Bindable var viewModel: ARMuseumViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                categorySection
                objectCaptureSection
            }
            .navigationTitle("作品を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.objectCaptureManager.reset()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        viewModel.addArtwork()
                        dismiss()
                    }
                    .disabled(viewModel.newArtworkTitle.isEmpty || viewModel.newArtworkArtist.isEmpty)
                }
            }
        }
    }

    // MARK: - Basic Info

    @ViewBuilder
    private var basicInfoSection: some View {
        Section("基本情報") {
            TextField("作品タイトル", text: $viewModel.newArtworkTitle)
            TextField("作者名", text: $viewModel.newArtworkArtist)
            TextField("説明（任意）", text: $viewModel.newArtworkDescription, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    // MARK: - Category

    @ViewBuilder
    private var categorySection: some View {
        Section("カテゴリ・展示方法") {
            Picker("カテゴリ", selection: $viewModel.newArtworkCategory) {
                ForEach(ArtworkCategory.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.systemImage)
                        .tag(category)
                }
            }

            Picker("展示方法", selection: $viewModel.newArtworkDisplayType) {
                ForEach(DisplayType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.systemImage)
                        .tag(type)
                }
            }
        }
    }

    // MARK: - Object Capture

    @ViewBuilder
    private var objectCaptureSection: some View {
        Section("3D スキャン（任意）") {
            let manager = viewModel.objectCaptureManager

            switch manager.captureState {
            case .idle:
                Button {
                    Task { await viewModel.startObjectCapture() }
                } label: {
                    Label("Object Capture でスキャン", systemImage: "cube")
                        .frame(maxWidth: .infinity)
                }

            case .capturing:
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("撮影中...")
                            .font(.subheadline)
                        Spacer()
                        Text("\(manager.capturedPhotoCount) / \(manager.requiredPhotoCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: Double(manager.capturedPhotoCount), total: Double(manager.requiredPhotoCount))
                        .tint(.indigo)
                }

            case .processing:
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("3D モデル生成中...")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(manager.processingProgress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: manager.processingProgress)
                        .tint(.orange)
                }

            case .completed:
                if let model = manager.capturedModel {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("スキャン完了", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.subheadline)

                        HStack {
                            Text("ファイル")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(model.fileName)
                        }
                        .font(.caption)

                        HStack {
                            Text("頂点数")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(model.formattedVertexCount)
                        }
                        .font(.caption)

                        HStack {
                            Text("サイズ")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(model.formattedFileSize)
                        }
                        .font(.caption)
                    }

                    Button {
                        manager.reset()
                    } label: {
                        Label("再スキャン", systemImage: "arrow.clockwise")
                    }
                }

            case .failed:
                Label("スキャンに失敗しました", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                Button {
                    manager.reset()
                } label: {
                    Label("再試行", systemImage: "arrow.clockwise")
                }
            }
        } footer: {
            Text("立体作品の場合、Object Capture で360度撮影して高品質な3Dモデルを生成できます。")
        }
    }
}

#Preview {
    AddArtworkView(viewModel: ARMuseumViewModel())
}
