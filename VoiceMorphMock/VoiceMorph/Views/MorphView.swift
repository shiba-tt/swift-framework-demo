import SwiftUI

struct MorphView: View {
    @Bindable var viewModel: VoiceMorphViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    engineStatusCard
                    if viewModel.isEngineRunning {
                        levelMetersSection
                        spectrumVisualizerSection
                        presetGridSection
                        parameterControlsSection
                        recordingControlSection
                    }
                }
                .padding()
            }
            .navigationTitle("VoiceMorph")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.resetToDefault()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(!viewModel.isEngineRunning)
                }
            }
        }
    }

    // MARK: - Engine Status

    private var engineStatusCard: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.isEngineRunning ? "mic.fill" : "mic.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(viewModel.isEngineRunning ? .green : .secondary)
                .symbolEffect(.pulse, isActive: viewModel.isEngineRunning)

            Text(viewModel.isEngineRunning ? "マイク入力中" : "マイクオフ")
                .font(.headline)

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.toggleEngine()
                }
            } label: {
                Label(
                    viewModel.isEngineRunning ? "停止" : "開始",
                    systemImage: viewModel.isEngineRunning ? "stop.fill" : "play.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isEngineRunning ? .red : .green)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Level Meters

    private var levelMetersSection: some View {
        VStack(spacing: 12) {
            Text("レベルメーター")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                levelMeter(label: "入力", level: viewModel.inputLevelNormalized, color: .green)
                levelMeter(label: "出力", level: viewModel.outputLevelNormalized, color: .blue)
            }

            Text(viewModel.inputLevelText)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func levelMeter(label: String, level: Float, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, level > 0.8 ? .red : color],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: geo.size.height * CGFloat(level))
                }
            }
            .frame(width: 24, height: 100)
        }
    }

    // MARK: - Spectrum Visualizer

    private var spectrumVisualizerSection: some View {
        VStack(spacing: 8) {
            Text("スペクトラム")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(viewModel.spectrumData.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(spectrumBarColor(for: Float(index) / Float(viewModel.spectrumData.count)))
                        .frame(height: max(4, CGFloat(value) * 80))
                }
            }
            .frame(height: 80)
            .animation(.easeOut(duration: 0.05), value: viewModel.spectrumData)

            HStack {
                Text("20Hz")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("20kHz")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func spectrumBarColor(for position: Float) -> Color {
        let hue = Double(position) * 0.7 + 0.15
        return Color(hue: hue, saturation: 0.8, brightness: 0.9)
    }

    // MARK: - Preset Grid

    private var presetGridSection: some View {
        VStack(spacing: 12) {
            Text("ボイスプリセット")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()),
                GridItem(.flexible()), GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(VoicePreset.allCases) { preset in
                    presetButton(preset)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func presetButton(_ preset: VoicePreset) -> some View {
        let isSelected = viewModel.selectedPreset == preset

        return Button {
            withAnimation(.spring(duration: 0.2)) {
                viewModel.selectPreset(preset)
            }
        } label: {
            VStack(spacing: 6) {
                Text(preset.emoji)
                    .font(.title2)
                Text(preset.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color.purple.opacity(0.2) : Color.clear,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }

    // MARK: - Parameter Controls

    private var parameterControlsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("カスタムパラメータ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    withAnimation { viewModel.showingCustomParameters.toggle() }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(viewModel.showingCustomParameters ? 0 : -90))
                }
            }

            if viewModel.showingCustomParameters {
                VStack(spacing: 16) {
                    parameterSlider(
                        label: "ピッチ", value: $viewModel.parameters.pitch,
                        range: VoiceParameters.pitchRange, unit: "cent",
                        icon: "music.note"
                    )
                    parameterSlider(
                        label: "リバーブ", value: $viewModel.parameters.reverb,
                        range: VoiceParameters.mixRange, unit: "%",
                        icon: "waveform.path"
                    )
                    parameterSlider(
                        label: "ディレイ", value: $viewModel.parameters.delay,
                        range: VoiceParameters.mixRange, unit: "%",
                        icon: "repeat"
                    )
                    parameterSlider(
                        label: "歪み", value: $viewModel.parameters.distortion,
                        range: VoiceParameters.mixRange, unit: "%",
                        icon: "bolt.fill"
                    )
                    parameterSlider(
                        label: "低音 EQ", value: $viewModel.parameters.eqLow,
                        range: VoiceParameters.eqRange, unit: "dB",
                        icon: "speaker.wave.1.fill"
                    )
                    parameterSlider(
                        label: "中音 EQ", value: $viewModel.parameters.eqMid,
                        range: VoiceParameters.eqRange, unit: "dB",
                        icon: "speaker.wave.2.fill"
                    )
                    parameterSlider(
                        label: "高音 EQ", value: $viewModel.parameters.eqHigh,
                        range: VoiceParameters.eqRange, unit: "dB",
                        icon: "speaker.wave.3.fill"
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func parameterSlider(
        label: String, value: Binding<Float>,
        range: ClosedRange<Float>, unit: String,
        icon: String
    ) -> some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundStyle(.purple)
                Text(label)
                    .font(.caption)
                Spacer()
                Text(String(format: "%.0f %@", value.wrappedValue, unit))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range)
                .tint(.purple)
        }
    }

    // MARK: - Recording Control

    private var recordingControlSection: some View {
        VStack(spacing: 12) {
            if viewModel.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                        .symbolEffect(.pulse)
                    Text("録音中")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    Spacer()
                    Text(viewModel.recordingDurationText)
                        .font(.title3.monospaced())
                        .foregroundStyle(.red)
                }
            }

            Button {
                withAnimation(.spring(duration: 0.2)) {
                    viewModel.toggleRecording()
                }
            } label: {
                Label(
                    viewModel.isRecording ? "録音停止" : "録音開始",
                    systemImage: viewModel.isRecording ? "stop.circle.fill" : "record.circle"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isRecording ? .orange : .red)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    MorphView(viewModel: VoiceMorphViewModel())
}
