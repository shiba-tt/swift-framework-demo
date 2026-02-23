import SwiftUI

struct OCRResultView: View {
    @Bindable var viewModel: HandwritingAIViewModel
    let ocrResult: OCRResult
    @Environment(\.dismiss) private var dismiss
    @State private var editedText: String = ""
    @State private var noteTitle = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    recognitionStats
                    originalPreview
                    recognizedTextSection
                    detectedShapesSection
                    layoutSection
                }
                .padding()
            }
            .navigationTitle("認識結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            isSaving = true
                            await viewModel.saveRecognizedNote(
                                title: noteTitle,
                                editedText: editedText
                            )
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("保存")
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .onAppear {
                editedText = ocrResult.recognizedText
                // タイトル自動推定
                noteTitle = ocrResult.recognizedText
                    .components(separatedBy: .newlines)
                    .first?
                    .trimmingCharacters(in: .whitespaces) ?? "無題"
            }
        }
    }

    // MARK: - Stats

    @ViewBuilder
    private var recognitionStats: some View {
        HStack(spacing: 12) {
            statPill(
                label: "認識精度",
                value: String(format: "%.0f%%", ocrResult.confidence * 100),
                color: ocrResult.confidence > 0.9 ? .green : .orange
            )
            statPill(
                label: "処理時間",
                value: String(format: "%.1f秒", ocrResult.processingTime),
                color: .blue
            )
            statPill(
                label: "レイアウト",
                value: ocrResult.layoutType.rawValue,
                color: ocrResult.layoutType.color
            )
        }
    }

    @ViewBuilder
    private func statPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1), in: .rect(cornerRadius: 10))
    }

    // MARK: - Original Preview

    @ViewBuilder
    private var originalPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("スキャン画像", systemImage: "photo")
                .font(.headline)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 120)
                .overlay {
                    VStack {
                        Image(systemName: "doc.text.image")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("スキャンされたノート画像")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
        }
    }

    // MARK: - Recognized Text

    @ViewBuilder
    private var recognizedTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("認識テキスト", systemImage: "text.alignleft")
                    .font(.headline)
                Spacer()
                Text("編集可能")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TextField("タイトル", text: $noteTitle)
                .font(.headline)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $editedText)
                .font(.body)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color(.systemGray6), in: .rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }

    // MARK: - Detected Shapes

    @ViewBuilder
    private var detectedShapesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("検出された図形", systemImage: "square.on.circle")
                .font(.headline)

            ForEach(ocrResult.detectedShapes) { shape in
                HStack {
                    Image(systemName: shape.shapeType.systemImage)
                        .foregroundStyle(.teal)
                        .frame(width: 24)
                    Text(shape.shapeType.rawValue)
                        .font(.subheadline)
                    Spacer()
                    if let text = shape.associatedText {
                        Text(text)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    // MARK: - Layout

    @ViewBuilder
    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("検出されたレイアウト", systemImage: "rectangle.3.group")
                .font(.headline)

            HStack {
                Image(systemName: ocrResult.layoutType.systemImage)
                    .font(.title2)
                    .foregroundStyle(ocrResult.layoutType.color)
                VStack(alignment: .leading) {
                    Text(ocrResult.layoutType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Core ML モデルによるレイアウト分類結果")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ocrResult.layoutType.color.opacity(0.1), in: .rect(cornerRadius: 10))
        }
    }
}

#Preview {
    OCRResultView(
        viewModel: HandwritingAIViewModel(),
        ocrResult: OCRResult(
            recognizedText: "テスト文書\n\n- 項目1\n- 項目2",
            detectedShapes: [
                DetectedShape(shapeType: .arrow, associatedText: "フロー"),
                DetectedShape(shapeType: .box, associatedText: "重要"),
            ],
            layoutType: .list,
            confidence: 0.93,
            processingTime: 2.1
        )
    )
}
