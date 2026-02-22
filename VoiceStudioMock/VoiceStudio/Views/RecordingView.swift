import SwiftUI

/// 収録画面：メーター + エフェクトチェーン概要 + 録音コントロール
struct RecordingView: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // 録音ステータス
                        RecordingStatusBanner(viewModel: viewModel)

                        // リアルタイムメーター
                        MeterSection(viewModel: viewModel)

                        // エフェクトチェーン概要
                        EffectChainOverview(viewModel: viewModel)

                        // プリセット選択
                        PresetSelector(viewModel: viewModel)
                    }
                    .padding()
                }

                // 録音コントロールバー
                RecordingControlBar(viewModel: viewModel)
            }
            .navigationTitle("VoiceStudio")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.toggleEngine() }
                    } label: {
                        Image(systemName: viewModel.isEngineRunning ? "power.circle.fill" : "power.circle")
                            .foregroundStyle(viewModel.isEngineRunning ? .green : .secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Recording Status Banner

private struct RecordingStatusBanner: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        if viewModel.isRecording {
            HStack(spacing: 10) {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)

                Text("REC")
                    .font(.headline)
                    .foregroundStyle(.red)

                Text(viewModel.recordingDuration)
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)

                Spacer()

                if let session = viewModel.currentSession {
                    Text(session.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Meter Section

private struct MeterSection: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("リアルタイムメーター")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Input メーター
            MeterBar(
                label: "Input",
                level: viewModel.audioMeter.inputLevel,
                peak: viewModel.audioMeter.inputPeak,
                dbText: formatDB(viewModel.audioMeter.inputLevel)
            )

            // Output メーター
            MeterBar(
                label: "Output",
                level: viewModel.audioMeter.outputLevel,
                peak: viewModel.audioMeter.outputPeak,
                dbText: formatDB(viewModel.audioMeter.outputLevel)
            )

            // Gain Reduction メーター
            HStack(spacing: 8) {
                Text("GR")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(width: 44, alignment: .leading)

                GeometryReader { geometry in
                    let width = geometry.size.width
                    let grWidth = min(CGFloat(viewModel.audioMeter.gainReduction / 20.0), 1.0) * width
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.15))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.yellow.gradient)
                            .frame(width: grWidth)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(height: 10)

                Text(String(format: "%.0f dB", -viewModel.audioMeter.gainReduction))
                    .font(.system(.caption, design: .monospaced))
                    .frame(width: 50, alignment: .trailing)
            }

            // LUFS 表示
            HStack {
                Text("LUFS")
                    .font(.caption)
                    .fontWeight(.medium)

                Text(String(format: "%.1f LUFS", viewModel.audioMeter.lufs))
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)

                Spacer()

                Text("Target: \(String(format: "%.0f", viewModel.targetLUFS))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(viewModel.lufsStatus.label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(viewModel.lufsStatus.color == "green" ? .systemGreen : viewModel.lufsStatus.color == "red" ? .systemRed : .systemYellow).opacity(0.15))
                    .foregroundStyle(Color(viewModel.lufsStatus.color == "green" ? .systemGreen : viewModel.lufsStatus.color == "red" ? .systemRed : .systemYellow))
                    .clipShape(Capsule())
            }

            // クリッピング警告
            if viewModel.audioMeter.isClipping {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text("クリッピング検出！ゲインを下げてください")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func formatDB(_ level: Float) -> String {
        if level <= 0 { return "-∞ dB" }
        let db = 20 * log10(level)
        return String(format: "%.0f dB", db)
    }
}

private struct MeterBar: View {
    let label: String
    let level: Float
    let peak: Float
    let dbText: String

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 44, alignment: .leading)

            GeometryReader { geometry in
                let width = geometry.size.width
                let levelWidth = CGFloat(level) * width
                let peakPosition = CGFloat(peak) * width

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.secondary.opacity(0.15))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(meterGradient)
                        .frame(width: min(levelWidth, width))

                    // ピークインジケーター
                    Rectangle()
                        .fill(peak > 0.9 ? .red : .white)
                        .frame(width: 2)
                        .offset(x: min(peakPosition, width - 2))
                }
            }
            .frame(height: 10)

            Text(dbText)
                .font(.system(.caption, design: .monospaced))
                .frame(width: 50, alignment: .trailing)
        }
    }

    private var meterGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .green, .yellow, .red],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Effect Chain Overview

private struct EffectChainOverview: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("エフェクトチェーン")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.enabledEffectCount)/\(viewModel.effects.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // チェーン表示（横並び）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    // マイク
                    Image(systemName: "mic.fill")
                        .font(.caption)
                        .foregroundStyle(.purple)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.sortedEffects) { effect in
                        EffectChip(effect: effect)

                        if effect.id != viewModel.sortedEffects.last?.id {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Image(systemName: "arrow.right")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)

                    // 出力
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundStyle(.purple)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct EffectChip: View {
    let effect: AudioEffect

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: effect.type.systemImageName)
                .font(.system(size: 9))
            Text(effect.name)
                .font(.system(size: 10))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(effect.isEnabled ? .purple.opacity(0.12) : .secondary.opacity(0.08))
        .foregroundStyle(effect.isEnabled ? .purple : .secondary)
        .clipShape(Capsule())
    }
}

// MARK: - Preset Selector

private struct PresetSelector: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("プリセット")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.presets) { preset in
                        Button {
                            viewModel.loadPreset(preset)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: preset.category.systemImageName)
                                    .font(.caption)
                                Text(preset.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedPreset?.id == preset.id
                                    ? .purple.opacity(0.15)
                                    : Color.secondary.opacity(0.08)
                            )
                            .foregroundStyle(
                                viewModel.selectedPreset?.id == preset.id
                                    ? .purple
                                    : .primary
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Recording Control Bar

private struct RecordingControlBar: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        HStack(spacing: 20) {
            // エンジン状態
            Circle()
                .fill(viewModel.isEngineRunning ? .green : .secondary)
                .frame(width: 8, height: 8)

            Spacer()

            // 録音ボタン
            Button {
                viewModel.toggleRecording()
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.isRecording ? .red : .red.opacity(0.15))
                        .frame(width: 56, height: 56)

                    if viewModel.isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .frame(width: 20, height: 20)
                    } else {
                        Circle()
                            .fill(.red)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .disabled(!viewModel.isEngineRunning)

            Spacer()

            // 録音時間
            if viewModel.isRecording {
                Text(viewModel.recordingDuration)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.red)
            } else {
                Text("READY")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
