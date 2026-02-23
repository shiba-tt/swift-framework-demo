import SwiftUI

struct AnalyzeView: View {
    @Bindable var viewModel: SoundScapeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    listeningControlCard
                    if viewModel.isListening {
                        decibelMeterSection
                        spectrumVisualizerSection
                        classificationSection
                        recordingSection
                    }
                }
                .padding()
            }
            .navigationTitle("SoundScape")
        }
    }

    // MARK: - Listening Control

    private var listeningControlCard: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.isListening ? "ear.and.waveform" : "ear")
                .font(.system(size: 48))
                .foregroundStyle(viewModel.isListening ? .cyan : .secondary)
                .symbolEffect(.pulse, isActive: viewModel.isListening)

            Text(viewModel.isListening ? "リスニング中..." : "環境音分析を開始")
                .font(.headline)

            if viewModel.isListening {
                Text("セッション: \(viewModel.sessionDurationText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.toggleListening()
                }
            } label: {
                Label(
                    viewModel.isListening ? "停止" : "開始",
                    systemImage: viewModel.isListening ? "stop.circle.fill" : "play.circle.fill"
                )
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isListening ? .red : .cyan)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Decibel Meter

    private var decibelMeterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("騒音レベル")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.noiseLevel.emoji) \(viewModel.noiseLevel.label)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .bottom, spacing: 4) {
                Text(String(format: "%.0f", viewModel.currentDecibel))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
                    .contentTransition(.numericText())

                VStack(alignment: .leading) {
                    Text("dB")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("ピーク: \(String(format: "%.0f", viewModel.peakDecibel)) dB")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
            }

            decibelBar

            Text(viewModel.noiseLevel.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var decibelBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.gray.opacity(0.15))

                RoundedRectangle(cornerRadius: 6)
                    .fill(decibelBarGradient)
                    .frame(width: geometry.size.width * decibelRatio)
                    .animation(.easeOut(duration: 0.15), value: viewModel.currentDecibel)
            }
        }
        .frame(height: 12)
    }

    private var decibelRatio: CGFloat {
        min(1.0, max(0, CGFloat(viewModel.currentDecibel) / 100.0))
    }

    private var decibelBarGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .yellow, .orange, .red],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Spectrum Visualizer

    private var spectrumVisualizerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("スペクトログラム")
                    .font(.headline)
                Spacer()
                Text("20Hz — 20kHz")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            spectrumBars

            HStack {
                Text("低音")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("中音")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("高音")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var spectrumBars: some View {
        HStack(alignment: .bottom, spacing: 2) {
            if let latest = viewModel.spectrumHistory.last {
                ForEach(Array(latest.bands.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(spectrumBarColor(for: index, total: latest.bands.count))
                        .frame(height: max(2, CGFloat(value) * 80))
                        .animation(.easeOut(duration: 0.15), value: value)
                }
            } else {
                ForEach(0..<32, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
        .frame(height: 80)
    }

    private func spectrumBarColor(for index: Int, total: Int) -> Color {
        let ratio = Double(index) / Double(total)
        if ratio < 0.33 {
            return .cyan
        } else if ratio < 0.66 {
            return .blue
        } else {
            return .purple
        }
    }

    // MARK: - AI Classification

    private var classificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI 音分類")
                    .font(.headline)
                Image(systemName: "brain")
                    .foregroundStyle(.cyan)
                Spacer()
                Text("リアルタイム")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.cyan.opacity(0.15))
                    .clipShape(Capsule())
            }

            ForEach(viewModel.currentClassifications) { classification in
                classificationRow(classification)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func classificationRow(_ classification: SoundClassification) -> some View {
        HStack(spacing: 12) {
            Text(classification.category.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(classification.category.rawValue)
                    .font(.subheadline)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray.opacity(0.15))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(classification.category.color)
                            .frame(width: geometry.size.width * classification.confidence)
                            .animation(.easeOut(duration: 0.2), value: classification.confidence)
                    }
                }
                .frame(height: 8)
            }

            Text("\(Int(classification.confidence * 100))%")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }

    // MARK: - Recording Control

    private var recordingSection: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleRecording()
            } label: {
                Label(
                    viewModel.isRecording ? "録音中" : "録音",
                    systemImage: viewModel.isRecording ? "record.circle.fill" : "record.circle"
                )
                .font(.subheadline.bold())
                .foregroundStyle(viewModel.isRecording ? .red : .primary)
            }
            .buttonStyle(.bordered)

            Spacer()

            Label("音マップ", systemImage: "map")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AnalyzeView(viewModel: SoundScapeViewModel())
}
