import SwiftUI

/// シンセサイザーメイン画面：シグナルフロー + パラメータ UI
struct SynthView: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 再生コントロール
                    PlaybackControlBar(viewModel: viewModel)

                    // シグナルフロー
                    SignalFlowView(viewModel: viewModel)

                    // 波形表示エリア
                    WaveformDisplaySection(viewModel: viewModel)

                    // 選択中モジュールのパラメータ
                    if let module = viewModel.selectedModule {
                        ModuleParameterView(viewModel: viewModel, module: module)
                    }

                    // レッスンヒント（レッスンモード時）
                    if let lesson = viewModel.currentLesson {
                        LessonHintCard(lesson: lesson, onComplete: {
                            viewModel.completeLesson()
                        })
                    }
                }
                .padding()
            }
            .navigationTitle("SynthLab")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("モード", selection: Binding(
                        get: { viewModel.currentMode },
                        set: { viewModel.currentMode = $0 }
                    )) {
                        ForEach(SynthLabViewModel.AppMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
        }
    }
}

// MARK: - Playback Control Bar

private struct PlaybackControlBar: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.togglePlayback()
            } label: {
                Image(systemName: viewModel.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(viewModel.isPlaying ? .red : .green)
            }

            // 出力レベルメーター
            VStack(alignment: .leading, spacing: 4) {
                Text("OUTPUT")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.quaternary)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(levelColor.gradient)
                            .frame(width: geometry.size.width * CGFloat(viewModel.audioEngine.outputLevel))
                    }
                }
                .frame(height: 8)
            }

            // レイテンシー表示
            VStack(spacing: 2) {
                Text(String(format: "%.1f ms", viewModel.audioEngine.latencyMs))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                Text("LATENCY")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var levelColor: Color {
        let level = viewModel.audioEngine.outputLevel
        if level > 0.8 { return .red }
        if level > 0.5 { return .yellow }
        return .green
    }
}

// MARK: - Signal Flow View

private struct SignalFlowView: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("シグナルフロー")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.modules) { module in
                        ModuleChip(
                            module: module,
                            isSelected: viewModel.selectedModule?.id == module.id
                        ) {
                            viewModel.selectedModule = module
                        }

                        if module.id != viewModel.modules.last?.id {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct ModuleChip: View {
    let module: SynthModule
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: module.type.icon)
                    .font(.system(size: 14))
                Text(module.type.rawValue)
                    .font(.system(size: 9, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? module.type.color.opacity(0.2)
                    : (module.isEnabled ? Color.secondary.opacity(0.08) : Color.secondary.opacity(0.03))
            )
            .foregroundStyle(module.isEnabled ? module.type.color : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? module.type.color : .clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Waveform Display Section

private struct WaveformDisplaySection: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                WaveformCard(title: "波形", data: viewModel.waveformData, color: .blue)
                WaveformCard(title: "フィルター応答", data: viewModel.filterResponseData, color: .orange)
            }
            HStack(spacing: 12) {
                WaveformCard(title: "エンベロープ", data: viewModel.envelopeData, color: .pink)
                WaveformCard(title: "LFO", data: viewModel.lfoData, color: .purple)
            }
        }
    }
}

private struct WaveformCard: View {
    let title: String
    let data: [Double]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)

            WaveformShape(data: data)
                .stroke(color.gradient, lineWidth: 1.5)
                .frame(height: 50)
                .background(color.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct WaveformShape: Shape {
    let data: [Double]

    func path(in rect: CGRect) -> Path {
        guard data.count > 1 else { return Path() }

        var path = Path()
        let stepX = rect.width / CGFloat(data.count - 1)
        let midY = rect.midY
        let scaleY = rect.height * 0.4

        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let y = midY - CGFloat(value) * scaleY
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

// MARK: - Module Parameter View

private struct ModuleParameterView: View {
    let viewModel: SynthLabViewModel
    let module: SynthModule

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: module.type.icon)
                    .foregroundStyle(module.type.color)
                Text("AUv3 パラメータ UI — \(module.type.rawValue)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Button {
                    viewModel.toggleModule(module)
                } label: {
                    Text(module.isEnabled ? "ON" : "OFF")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(module.isEnabled ? module.type.color.opacity(0.2) : .secondary.opacity(0.1))
                        .foregroundStyle(module.isEnabled ? module.type.color : .secondary)
                        .clipShape(Capsule())
                }
            }

            // 波形/フィルタータイプ切り替え
            if module.type == .oscillator {
                WaveformTypePicker(viewModel: viewModel)
            }
            if module.type == .filter {
                FilterTypePicker(viewModel: viewModel)
            }

            // パラメータスライダー
            ForEach(module.parameters) { param in
                ParameterSliderRow(
                    parameter: param,
                    color: module.type.color
                ) { newValue in
                    viewModel.updateParameter(
                        moduleID: module.id,
                        parameterID: param.id,
                        value: newValue
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct WaveformTypePicker: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        HStack(spacing: 6) {
            Text("波形:")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(WaveformType.allCases) { type in
                Button {
                    viewModel.setWaveform(type)
                } label: {
                    Text(type.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.waveformType == type ? Color.blue.opacity(0.2) : .secondary.opacity(0.08))
                        .foregroundStyle(viewModel.waveformType == type ? .blue : .secondary)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private struct FilterTypePicker: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        HStack(spacing: 6) {
            Text("タイプ:")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(FilterType.allCases) { type in
                Button {
                    viewModel.setFilterType(type)
                } label: {
                    Text(type.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.filterType == type ? Color.orange.opacity(0.2) : .secondary.opacity(0.08))
                        .foregroundStyle(viewModel.filterType == type ? .orange : .secondary)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private struct ParameterSliderRow: View {
    let parameter: SynthParameter
    let color: Color
    let onChange: (Double) -> Void

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(parameter.name)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                Spacer()
                Text(parameter.displayText)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { parameter.value },
                    set: { onChange($0) }
                ),
                in: parameter.minValue...parameter.maxValue,
                step: parameter.step
            )
            .tint(color)
        }
    }
}

// MARK: - Lesson Hint Card

private struct LessonHintCard: View {
    let lesson: Lesson
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Lesson \(lesson.number): \(lesson.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text(lesson.hint)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            ForEach(lesson.steps) { step in
                HStack(spacing: 8) {
                    Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(step.isCompleted ? .green : .secondary)
                        .font(.caption)
                    Text(step.instruction)
                        .font(.caption)
                        .foregroundStyle(step.isCompleted ? .secondary : .primary)
                }
            }

            Button("レッスン完了", action: onComplete)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.indigo.opacity(0.15))
                .foregroundStyle(.indigo)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.yellow.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
