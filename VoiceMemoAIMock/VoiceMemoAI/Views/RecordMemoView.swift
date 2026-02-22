import SwiftUI

// MARK: - RecordMemoView

struct RecordMemoView: View {
    @Bindable var viewModel: VoiceMemoAIViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAnalysis = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // ステータス表示
                statusSection

                // トランスクリプション表示
                transcriptionSection

                Spacer()

                // 録音ボタン
                recordButton

                // 解析中インジケーター
                if viewModel.isAnalyzing {
                    analysisIndicator
                }

                Spacer()
            }
            .padding()
            .navigationTitle("音声メモを録音")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        if viewModel.isRecording {
                            _ = viewModel.stopRecordingAndAnalyze()
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(spacing: 12) {
            if viewModel.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .opacity(pulsingOpacity)
                    Text("録音中")
                        .font(.headline)
                        .foregroundStyle(.red)
                }

                Text(formattedDuration)
                    .font(.system(.title, design: .monospaced))
                    .foregroundStyle(.secondary)
            } else if viewModel.isAnalyzing {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("AI が構造化中...")
                        .font(.headline)
                        .foregroundStyle(.indigo)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.indigo.opacity(0.3))
                    Text("ボタンを押して録音開始")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Transcription Section

    private var transcriptionSection: some View {
        Group {
            if !viewModel.currentTranscription.isEmpty || viewModel.isRecording {
                ScrollView {
                    Text(viewModel.currentTranscription.isEmpty ? "音声を認識しています..." : viewModel.currentTranscription)
                        .font(.body)
                        .foregroundStyle(viewModel.currentTranscription.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(maxHeight: 200)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Record Button

    private var recordButton: some View {
        Button {
            if viewModel.isRecording {
                Task {
                    await viewModel.stopRecordingAndAnalyze()
                    dismiss()
                }
            } else {
                viewModel.startRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(viewModel.isRecording ? .red.opacity(0.15) : .indigo.opacity(0.15))
                    .frame(width: 96, height: 96)

                Circle()
                    .fill(viewModel.isRecording ? .red : .indigo)
                    .frame(width: 72, height: 72)

                if viewModel.isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
            }
        }
        .disabled(viewModel.isAnalyzing)
    }

    // MARK: - Analysis Indicator

    private var analysisIndicator: some View {
        VStack(spacing: 8) {
            ProgressView()
            if let progress = viewModel.analysisProgress {
                Text(progress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        let minutes = Int(viewModel.recordingDuration) / 60
        let seconds = Int(viewModel.recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @State private var pulsingOpacity: Double = 1.0

    private func startPulse() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulsingOpacity = 0.3
        }
    }
}
