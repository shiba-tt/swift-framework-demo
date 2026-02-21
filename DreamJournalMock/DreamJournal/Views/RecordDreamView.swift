import SwiftUI

// MARK: - RecordDreamView（夢の記録画面）

struct RecordDreamView: View {
    @Bindable var viewModel: DreamJournalViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var speechManager = SpeechRecognitionManager.shared
    @State private var manualText = ""
    @State private var lucidity = 3
    @State private var vividness = 3
    @State private var inputMode: InputMode = .voice
    @State private var isSaving = false

    enum InputMode: String, CaseIterable {
        case voice = "音声"
        case text = "テキスト"
    }

    private var currentTranscription: String {
        inputMode == .voice ? speechManager.transcription : manualText
    }

    private var canSave: Bool {
        !currentTranscription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 入力モード選択
                    inputModePicker

                    // 入力エリア
                    if inputMode == .voice {
                        voiceInputSection
                    } else {
                        textInputSection
                    }

                    // プレビュー
                    if !currentTranscription.isEmpty {
                        transcriptionPreview
                    }

                    // メタ情報スライダー
                    metadataSliders

                    // 保存ボタン
                    saveButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("夢を記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        speechManager.stopRecording()
                        dismiss()
                    }
                }
            }
            .task {
                _ = await speechManager.requestAuthorization()
            }
        }
    }

    // MARK: - Input Mode Picker

    private var inputModePicker: some View {
        Picker("入力モード", selection: $inputMode) {
            ForEach(InputMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Voice Input Section

    private var voiceInputSection: some View {
        VStack(spacing: 20) {
            // 音声波形インジケーター
            HStack(spacing: 3) {
                ForEach(0..<20, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(speechManager.isRecording ? .purple : .gray.opacity(0.3))
                        .frame(width: 4, height: barHeight(for: i))
                        .animation(
                            .easeInOut(duration: 0.15).delay(Double(i) * 0.02),
                            value: speechManager.audioLevel
                        )
                }
            }
            .frame(height: 60)

            // 録音時間
            if speechManager.isRecording {
                Text(speechManager.formattedDuration)
                    .font(.title2)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .foregroundStyle(.purple)
            }

            // 録音ボタン
            Button {
                Task {
                    if speechManager.isRecording {
                        speechManager.stopRecording()
                    } else {
                        try? await speechManager.startRecording()
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(speechManager.isRecording ? .red : .purple)
                        .frame(width: 72, height: 72)

                    if speechManager.isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }
            }

            Text(speechManager.isRecording ? "タップして停止" : "タップして録音開始")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !speechManager.isAuthorized {
                Text("マイクと音声認識の権限を許可してください")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Text Input Section

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("夢の内容を入力")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextEditor(text: $manualText)
                .frame(minHeight: 150)
                .padding(8)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary)
                )

            Text("\(manualText.count) 文字")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Transcription Preview

    private var transcriptionPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "text.quote")
                    .foregroundStyle(.purple)
                Text("文字起こし結果")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text(currentTranscription)
                .font(.body)
                .lineSpacing(4)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.purple.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Metadata Sliders

    private var metadataSliders: some View {
        VStack(spacing: 16) {
            // 明晰度
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "eye")
                        .foregroundStyle(.blue)
                    Text("明晰度")
                        .font(.subheadline)
                    Spacer()
                    Text(lucidityLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Picker("明晰度", selection: $lucidity) {
                    ForEach(1...5, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }

            // 鮮明度
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "paintbrush")
                        .foregroundStyle(.orange)
                    Text("鮮明度")
                        .font(.subheadline)
                    Spacer()
                    Text(vividnessLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Picker("鮮明度", selection: $vividness) {
                    ForEach(1...5, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            save()
        } label: {
            HStack {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(isSaving ? "保存中..." : "保存して AI 分析")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSave ? .purple : .gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!canSave)
    }

    // MARK: - Helpers

    private func save() {
        guard canSave else { return }
        isSaving = true
        speechManager.stopRecording()

        Task {
            await viewModel.saveDream(
                transcription: currentTranscription,
                lucidity: lucidity,
                vividness: vividness
            )
            isSaving = false
            dismiss()
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        guard speechManager.isRecording else { return 8 }
        let base = CGFloat.random(in: 8...40)
        return base * CGFloat(speechManager.audioLevel + 0.2)
    }

    private var lucidityLabel: String {
        switch lucidity {
        case 1: "ぼんやり"
        case 2: "薄い"
        case 3: "普通"
        case 4: "はっきり"
        case 5: "完全に自覚"
        default: ""
        }
    }

    private var vividnessLabel: String {
        switch vividness {
        case 1: "かすか"
        case 2: "ぼんやり"
        case 3: "普通"
        case 4: "鮮明"
        case 5: "超鮮明"
        default: ""
        }
    }
}
