import SwiftUI

struct ListeningView: View {
    var viewModel: SoundTranslatorViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Main listening control
                    listeningControl

                    if viewModel.isListening {
                        // Audio level
                        audioLevelIndicator

                        // Situation summary
                        if let summary = viewModel.currentSummary {
                            summaryCard(summary)
                        }

                        // Direction radar
                        directionRadar

                        // Recent sounds
                        recentSoundsSection
                    } else {
                        // Start prompt
                        startPrompt
                    }
                }
                .padding()
            }
            .navigationTitle("環境音翻訳機")
            .toolbar {
                if viewModel.isListening {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                            Text("リスニング中")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Listening Control

    private var listeningControl: some View {
        Button {
            viewModel.toggleListening()
        } label: {
            ZStack {
                // Outer ring animation
                Circle()
                    .stroke(
                        viewModel.isListening ? Color.teal.opacity(0.3) : Color.gray.opacity(0.2),
                        lineWidth: 4
                    )
                    .frame(width: 140, height: 140)

                if viewModel.isListening {
                    // Pulsing rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.teal.opacity(0.15), lineWidth: 2)
                            .frame(
                                width: 140 + CGFloat(i) * 30,
                                height: 140 + CGFloat(i) * 30
                            )
                    }
                }

                Circle()
                    .fill(viewModel.isListening ? .teal : .gray)
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Image(systemName: viewModel.isListening ? "ear.fill" : "ear")
                        .font(.system(size: 36))
                    Text(viewModel.isListening ? "停止" : "開始")
                        .font(.caption.bold())
                }
                .foregroundStyle(.white)
            }
        }
        .padding(.top)
    }

    // MARK: - Audio Level

    private var audioLevelIndicator: some View {
        VStack(spacing: 8) {
            HStack(spacing: 3) {
                ForEach(0..<20, id: \.self) { i in
                    let threshold = Double(i) / 20.0
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: threshold))
                        .frame(width: 12, height: viewModel.audioLevel > threshold ? 30 : 10)
                        .animation(.easeInOut(duration: 0.15), value: viewModel.audioLevel)
                }
            }
            .frame(height: 30)

            Text("音量レベル: \(Int(viewModel.audioLevel * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func barColor(for threshold: Double) -> Color {
        if threshold > 0.8 { return .red }
        if threshold > 0.6 { return .orange }
        return .teal
    }

    // MARK: - Summary Card

    private func summaryCard(_ summary: SituationSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .foregroundStyle(.teal)
                Text("AI 状況分析")
                    .font(.headline)
                Spacer()
                Label(summary.alertLevel.rawValue, systemImage: summary.alertLevel.systemImage)
                    .font(.caption.bold())
                    .foregroundStyle(summary.alertLevel.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(summary.alertLevel.color.opacity(0.15), in: Capsule())
            }

            Text(summary.description)
                .font(.body)
                .foregroundStyle(.primary)

            if !summary.soundEvents.isEmpty {
                Divider()
                HStack(spacing: 12) {
                    ForEach(summary.soundEvents.prefix(3)) { event in
                        Label(event.label, systemImage: event.category.systemImage)
                            .font(.caption)
                            .foregroundStyle(event.category.color)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Direction Radar

    private var directionRadar: some View {
        VStack(spacing: 8) {
            Text("音の方向")
                .font(.headline)

            ZStack {
                // Radar circles
                Circle()
                    .stroke(.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: 160, height: 160)
                Circle()
                    .stroke(.gray.opacity(0.15), lineWidth: 1)
                    .frame(width: 110, height: 110)
                Circle()
                    .stroke(.gray.opacity(0.1), lineWidth: 1)
                    .frame(width: 60, height: 60)

                // Direction labels
                Text("前")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .offset(y: -90)
                Text("後")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .offset(y: 90)
                Text("左")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .offset(x: -90)
                Text("右")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .offset(x: 90)

                // Center (user)
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.teal)

                // Sound dots
                ForEach(viewModel.detectedSounds.prefix(5)) { event in
                    if let direction = event.direction {
                        soundDot(event: event, direction: direction)
                    }
                }
            }
            .frame(width: 200, height: 200)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func soundDot(event: SoundEvent, direction: SoundDirection) -> some View {
        let offset = directionOffset(direction)
        return Image(systemName: event.category.systemImage)
            .font(.caption)
            .foregroundStyle(event.alertLevel.color)
            .offset(x: offset.x, y: offset.y)
    }

    private func directionOffset(_ direction: SoundDirection) -> CGPoint {
        let distance: CGFloat = 55
        switch direction {
        case .front: return CGPoint(x: 0, y: -distance)
        case .back: return CGPoint(x: 0, y: distance)
        case .left: return CGPoint(x: -distance, y: 0)
        case .right: return CGPoint(x: distance, y: 0)
        case .above: return CGPoint(x: 0, y: -30)
        case .unknown: return CGPoint(x: 20, y: 20)
        }
    }

    // MARK: - Recent Sounds

    private var recentSoundsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("検出された音")
                .font(.headline)

            ForEach(viewModel.detectedSounds.prefix(5)) { event in
                SoundEventRow(event: event)
            }

            if viewModel.detectedSounds.isEmpty {
                ContentUnavailableView(
                    "音を検出中...",
                    systemImage: "waveform",
                    description: Text("周囲の音を分析しています")
                )
                .frame(height: 120)
            }
        }
    }

    // MARK: - Start Prompt

    private var startPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.and.mic")
                .font(.system(size: 60))
                .foregroundStyle(.teal.opacity(0.5))

            Text("マイクボタンをタップして\n環境音のリスニングを開始")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Features
            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "waveform.circle", title: "300種以上の音を認識", desc: "SoundAnalysis で環境音をリアルタイム分類")
                featureRow(icon: "text.bubble", title: "会話の文字起こし", desc: "Speech Framework で周囲の会話を翻訳")
                featureRow(icon: "brain.head.profile.fill", title: "AI状況分析", desc: "Foundation Models で状況を自然言語で要約")
                featureRow(icon: "iphone.radiowaves.left.and.right", title: "触覚フィードバック", desc: "危険な音をバイブレーションで即座に通知")
                featureRow(icon: "applewatch", title: "Apple Watch 連携", desc: "手首の振動で安全を常時サポート")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.top)
    }

    private func featureRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.teal)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - SoundEventRow

struct SoundEventRow: View {
    let event: SoundEvent

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(event.category.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: event.category.systemImage)
                    .font(.body)
                    .foregroundStyle(event.category.color)
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(event.label)
                        .font(.subheadline.bold())

                    if event.alertLevel != .safe {
                        Image(systemName: event.alertLevel.systemImage)
                            .font(.caption)
                            .foregroundStyle(event.alertLevel.color)
                    }
                }

                HStack(spacing: 8) {
                    Text("精度: \(event.confidencePercent)%")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let direction = event.direction {
                        Label(direction.rawValue, systemImage: direction.systemImage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text(event.formattedTime)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ListeningView(viewModel: SoundTranslatorViewModel())
}
