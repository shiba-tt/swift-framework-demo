import SwiftUI

// MARK: - PedalBoardView（エフェクトボード画面）

struct PedalBoardView: View {
    @Bindable var viewModel: PedalBoardViewModel
    @State private var showingAddPedal = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // トップバー: メーター & コントロール
                topControlBar

                // エフェクトチェーン
                if viewModel.pedals.isEmpty {
                    emptyBoardView
                } else {
                    pedalChainView
                }

                // ボトムバー: 録音 & チューナー
                bottomToolbar
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color.brown.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("PedalBoard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPedal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    // エンジン ON/OFF
                    Button {
                        Task { await viewModel.toggleEngine() }
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(viewModel.isEngineRunning ? .green : .red)
                                .frame(width: 8, height: 8)
                            Text(viewModel.isEngineRunning ? "ON" : "OFF")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddPedal) {
                AddPedalView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingTuner) {
                TunerView(viewModel: viewModel)
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Top Control Bar

    private var topControlBar: some View {
        VStack(spacing: 8) {
            // シグナルフロー表示
            HStack(spacing: 4) {
                Image(systemName: "guitars")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("INPUT")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                // アクティブエフェクト数
                Text("\(viewModel.enabledPedalCount)/\(viewModel.totalPedalCount)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)

                Spacer()

                Text("OUTPUT")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Image(systemName: "speaker.wave.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // レベルメーター
            HStack(spacing: 8) {
                LevelMeterView(
                    label: "IN",
                    level: viewModel.audioMeter.inputLevel,
                    peak: viewModel.audioMeter.inputPeak
                )
                LevelMeterView(
                    label: "OUT",
                    level: viewModel.audioMeter.outputLevel,
                    peak: viewModel.audioMeter.outputPeak
                )
            }
            .padding(.horizontal)

            // レイテンシー表示
            if viewModel.isEngineRunning {
                Text(String(format: "Latency: %.1f ms", viewModel.audioMeter.latencyMs))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: - Empty Board

    private var emptyBoardView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "guitars.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange.opacity(0.5))

            Text("ペダルを追加しましょう")
                .font(.title2)
                .fontWeight(.semibold)

            Text("＋ ボタンからエフェクトペダルを追加するか\nプリセットを読み込んでください")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button {
                    showingAddPedal = true
                } label: {
                    Label("ペダル追加", systemImage: "plus")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Button {
                    // 最初のプリセットを読み込み
                    if let first = viewModel.presets.first {
                        viewModel.loadPreset(first)
                    }
                } label: {
                    Label("プリセット", systemImage: "slider.horizontal.3")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Pedal Chain

    private var pedalChainView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // シグナル入力インジケーター
                signalFlowIndicator(label: "🎸 Input")

                // ペダルチェーン
                ForEach(viewModel.sortedPedals) { pedal in
                    VStack(spacing: 0) {
                        // 接続線
                        signalLine(isActive: pedal.isEnabled)

                        // ペダルカード
                        PedalCardView(pedal: pedal, viewModel: viewModel)
                            .padding(.horizontal)
                    }
                }

                // シグナル出力
                signalLine(isActive: true)
                signalFlowIndicator(label: "🔊 Output")
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - Bottom Toolbar

    private var bottomToolbar: some View {
        HStack(spacing: 24) {
            // チューナー
            Button {
                viewModel.toggleTuner()
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "tuningfork")
                        .font(.title3)
                    Text("チューナー")
                        .font(.caption2)
                }
                .foregroundStyle(viewModel.showingTuner ? .orange : .secondary)
            }

            Spacer()

            // 録音
            Button {
                viewModel.toggleRecording()
            } label: {
                VStack(spacing: 2) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? .red : .gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                        if viewModel.isRecording {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.white)
                                .frame(width: 14, height: 14)
                        } else {
                            Circle()
                                .fill(.red)
                                .frame(width: 18, height: 18)
                        }
                    }
                    if viewModel.isRecording {
                        Text(viewModel.recordingDuration)
                            .font(.caption2)
                            .monospacedDigit()
                            .foregroundStyle(.red)
                    } else {
                        Text("録音")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // プリセット名表示
            VStack(spacing: 2) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                Text(viewModel.selectedPreset?.name ?? "カスタム")
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Signal Flow Helpers

    private func signalFlowIndicator(label: String) -> some View {
        Text(label)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.quaternary)
            .clipShape(Capsule())
    }

    private func signalLine(isActive: Bool) -> some View {
        Rectangle()
            .fill(isActive ? Color.orange.opacity(0.6) : Color.gray.opacity(0.2))
            .frame(width: 2, height: 16)
    }
}

// MARK: - PedalCardView（ペダルカード）

struct PedalCardView: View {
    let pedal: EffectPedal
    @Bindable var viewModel: PedalBoardViewModel
    @State private var showingDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // ペダルヘッダー
            HStack {
                Text(pedal.emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(pedal.name)
                        .font(.headline)
                        .foregroundStyle(pedal.isEnabled ? .primary : .secondary)
                    if let presetName = pedal.presetName {
                        Text(presetName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // ON/OFF ボタン
                Button {
                    viewModel.togglePedal(pedal)
                } label: {
                    Text(pedal.isEnabled ? "ON" : "OFF")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(pedal.isEnabled ? Color(pedal.colorName) : .gray.opacity(0.3))
                        .foregroundStyle(pedal.isEnabled ? .white : .secondary)
                        .clipShape(Capsule())
                }

                // 詳細ボタン
                Button {
                    showingDetail = true
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // パラメータスライダー（コンパクト表示）
            if pedal.isEnabled {
                VStack(spacing: 6) {
                    ForEach(Array(pedal.parameters.enumerated()), id: \.element.id) { index, param in
                        HStack(spacing: 8) {
                            Text(param.name)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .leading)

                            Slider(
                                value: Binding(
                                    get: { param.value },
                                    set: { viewModel.updateParameter(pedalID: pedal.id, parameterIndex: index, value: $0) }
                                ),
                                in: param.range
                            )
                            .tint(Color(pedal.colorName))

                            Text(param.formattedValue)
                                .font(.caption2)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                                .frame(width: 55, alignment: .trailing)
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.background)
                .shadow(color: pedal.isEnabled ? Color(pedal.colorName).opacity(0.2) : .clear, radius: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(pedal.isEnabled ? Color(pedal.colorName).opacity(0.4) : .clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: pedal.isEnabled)
        .sheet(isPresented: $showingDetail) {
            PedalDetailView(pedal: pedal, viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .contextMenu {
            Button(role: .destructive) {
                viewModel.removePedal(pedal)
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }
}

// MARK: - LevelMeterView

struct LevelMeterView: View {
    let label: String
    let level: Float
    let peak: Float

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.quaternary)

                        // レベル
                        RoundedRectangle(cornerRadius: 2)
                            .fill(meterColor)
                            .frame(width: geometry.size.width * CGFloat(min(level, 1)))

                        // ピーク
                        if peak > 0.01 {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 2)
                                .offset(x: geometry.size.width * CGFloat(min(peak, 1)) - 1)
                        }
                    }
                }
                .frame(height: 6)

                Text(String(format: "%.0f", levelToDecibels(level)))
                    .font(.system(size: 8))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
            }
        }
    }

    private var meterColor: Color {
        if level > 0.9 { return .red }
        if level > 0.7 { return .yellow }
        return .green
    }

    private func levelToDecibels(_ level: Float) -> Float {
        guard level > 0 else { return -60 }
        return max(20 * log10(level), -60)
    }
}
