import SwiftUI

/// 空間オーディオフィールド画面：リスナーをレーダー表示し、ゾーン別エフェクトを可視化
struct SoundFieldView: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 再生中トラック情報
                NowPlayingBar(viewModel: viewModel)

                // フィールドビュー
                FieldRadarView(viewModel: viewModel)

                // ゾーン凡例
                ZoneLegendBar()

                // 再生コントロール
                PlaybackControlBar(viewModel: viewModel)
            }
            .navigationTitle("SoundField")
            .sheet(isPresented: Binding(
                get: { viewModel.showListenerDetail },
                set: { viewModel.showListenerDetail = $0 }
            )) {
                if let listener = viewModel.selectedListener {
                    ListenerDetailSheet(viewModel: viewModel, listener: listener)
                }
            }
        }
    }
}

// MARK: - Now Playing Bar

private struct NowPlayingBar: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        HStack(spacing: 10) {
            if let track = viewModel.audioManager.currentTrack {
                Image(systemName: track.genre.icon)
                    .foregroundStyle(track.genre.color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("NOW PLAYING")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text("\(track.title) — \(track.artist)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
            } else {
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
                Text("トラックを選択してください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(viewModel.audioManager.listeners.count) 人")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.green)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Field Radar View

private struct FieldRadarView: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let maxRadius = min(geometry.size.width, geometry.size.height) / 2 - 40

            ZStack {
                // ゾーンリング
                ZoneRing(zone: .far, maxRadius: maxRadius, ringIndex: 4)
                ZoneRing(zone: .mid, maxRadius: maxRadius, ringIndex: 3)
                ZoneRing(zone: .near, maxRadius: maxRadius, ringIndex: 2)
                ZoneRing(zone: .intimate, maxRadius: maxRadius, ringIndex: 1)

                // 距離ラベル
                ForEach([(1, "1m"), (3, "3m"), (6, "6m"), (10, "10m")], id: \.0) { index, label in
                    Text(label)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .offset(y: -maxRadius * CGFloat(index) / 4 - 8)
                }

                // 中心（ホスト音源）
                VStack(spacing: 4) {
                    ZStack {
                        // パルスエフェクト（再生中）
                        if viewModel.audioManager.isPlaying {
                            Circle()
                                .fill(.green.opacity(0.15))
                                .frame(width: 50, height: 50)
                        }
                        Circle()
                            .fill(.green.gradient)
                            .frame(width: 32, height: 32)
                        Image(systemName: "music.note.house.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Text("HOST")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                }

                // リスナードット
                ForEach(viewModel.audioManager.listeners) { listener in
                    ListenerDot(viewModel: viewModel, listener: listener)
                        .position(listenerPosition(
                            listener: listener,
                            center: center,
                            maxRadius: maxRadius
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }

    private func listenerPosition(listener: Listener, center: CGPoint, maxRadius: CGFloat) -> CGPoint {
        let normalizedDistance = min(CGFloat(listener.distance) / 10.0, 1.0) * maxRadius
        let angle = atan2(CGFloat(listener.direction.x), CGFloat(-listener.direction.z))
        return CGPoint(
            x: center.x + normalizedDistance * sin(angle),
            y: center.y - normalizedDistance * cos(angle)
        )
    }
}

private struct ZoneRing: View {
    let zone: SoundZone
    let maxRadius: CGFloat
    let ringIndex: Int

    var body: some View {
        Circle()
            .fill(zone.color.opacity(0.03))
            .overlay(
                Circle()
                    .stroke(zone.color.opacity(0.15), lineWidth: 1)
            )
            .frame(
                width: maxRadius * 2 * CGFloat(ringIndex) / 4,
                height: maxRadius * 2 * CGFloat(ringIndex) / 4
            )
    }
}

private struct ListenerDot: View {
    let viewModel: SoundFieldViewModel
    let listener: Listener

    var body: some View {
        Button {
            viewModel.selectedListener = listener
            viewModel.showListenerDetail = true
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(listener.zone.color.gradient)
                        .frame(width: 28, height: 28)
                    Image(systemName: "ear.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(listener.name)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.primary)

                HStack(spacing: 2) {
                    Image(systemName: listener.zone.icon)
                        .font(.system(size: 7))
                    Text(listener.distanceText)
                        .font(.system(size: 7, design: .monospaced))
                }
                .foregroundStyle(listener.zone.color)
            }
        }
    }
}

// MARK: - Zone Legend Bar

private struct ZoneLegendBar: View {
    var body: some View {
        HStack(spacing: 16) {
            ForEach([SoundZone.intimate, .near, .mid, .far], id: \.rawValue) { zone in
                HStack(spacing: 4) {
                    Circle()
                        .fill(zone.color)
                        .frame(width: 8, height: 8)
                    Text(zone.displayName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Playback Control Bar

private struct PlaybackControlBar: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        VStack(spacing: 8) {
            // 進捗バー
            if viewModel.audioManager.currentTrack != nil {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.quaternary)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.green.gradient)
                            .frame(width: geometry.size.width * viewModel.audioManager.playbackProgress)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal)
            }

            // コントロールボタン
            HStack(spacing: 24) {
                Button {
                    viewModel.audioManager.stopPlayback()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                }
                .disabled(viewModel.audioManager.currentTrack == nil)

                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .disabled(viewModel.audioManager.currentTrack == nil)

                // ボリューム
                HStack(spacing: 6) {
                    Image(systemName: "speaker.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Slider(
                        value: Binding(
                            get: { viewModel.audioManager.masterVolume },
                            set: { viewModel.audioManager.masterVolume = $0 }
                        ),
                        in: 0...1.0
                    )
                    .tint(.green)
                    .frame(width: 100)
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Listener Detail Sheet

private struct ListenerDetailSheet: View {
    let viewModel: SoundFieldViewModel
    let listener: Listener
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            let params = viewModel.effectParams(for: listener)

            VStack(spacing: 20) {
                // リスナー情報
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(listener.zone.color.gradient)
                            .frame(width: 60, height: 60)
                        Image(systemName: "ear.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }

                    Text(listener.name)
                        .font(.headline)
                    Text("\(listener.distanceText) — \(listener.zone.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(listener.zone.color)
                }

                // エフェクトパラメータ
                VStack(alignment: .leading, spacing: 12) {
                    Text("適用エフェクト")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    EffectMeter(label: "音量", value: params.volume, color: .green)
                    EffectMeter(label: "Bass", value: params.bassBoost, color: .red)
                    EffectMeter(label: "Reverb", value: params.reverb, color: .blue)
                    EffectMeter(label: "Pan", value: (params.pan + 1) / 2, color: .purple)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // ゾーン説明
                VStack(alignment: .leading, spacing: 8) {
                    Text("ゾーン: \(listener.zone.displayName)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(listener.zone.effectDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(listener.zone.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
            .navigationTitle("リスナー詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

private struct EffectMeter: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .frame(width: 50, alignment: .trailing)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.gradient)
                        .frame(width: geometry.size.width * value)
                }
            }
            .frame(height: 8)

            Text(String(format: "%.0f%%", value * 100))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}
