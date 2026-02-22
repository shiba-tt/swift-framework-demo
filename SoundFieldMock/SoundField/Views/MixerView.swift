import SwiftUI

/// ミキサー画面：リスナー別のエフェクトパラメータを表示
struct MixerView: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.audioManager.listeners.isEmpty {
                    ContentUnavailableView(
                        "リスナーがいません",
                        systemImage: "ear.trianglebadge.exclamationmark",
                        description: Text("近くのデバイスがセッションに参加するのを待っています")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // マスターボリューム
                            MasterVolumeSection(viewModel: viewModel)

                            // リスナー別エフェクト
                            ForEach(viewModel.audioManager.listeners) { listener in
                                ListenerMixerCard(viewModel: viewModel, listener: listener)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("ミキサー")
        }
    }
}

// MARK: - Master Volume Section

private struct MasterVolumeSection: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
                Text("マスターボリューム")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(
                    value: Binding(
                        get: { viewModel.audioManager.masterVolume },
                        set: { viewModel.audioManager.masterVolume = $0 }
                    ),
                    in: 0...1.0
                )
                .tint(.green)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f%%", viewModel.audioManager.masterVolume * 100))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .frame(width: 36)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Listener Mixer Card

private struct ListenerMixerCard: View {
    let viewModel: SoundFieldViewModel
    let listener: Listener

    var body: some View {
        let params = viewModel.effectParams(for: listener)

        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                ZStack {
                    Circle()
                        .fill(listener.zone.color.gradient)
                        .frame(width: 32, height: 32)
                    Image(systemName: "ear.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(listener.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(listener.distanceText) — \(listener.zone.displayName)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(listener.zone.color)
                }

                Spacer()

                Text(listener.zone.effectDescription)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(listener.zone.color.opacity(0.1))
                    .clipShape(Capsule())
            }

            // エフェクトバー
            VStack(spacing: 6) {
                MixerBar(label: "VOL", value: params.volume, color: .green)
                MixerBar(label: "BASS", value: params.bassBoost, color: .red)
                MixerBar(label: "REV", value: params.reverb, color: .blue)
                MixerBar(label: "PAN", value: (params.pan + 1) / 2, color: .purple)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct MixerBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.quaternary)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.gradient)
                        .frame(width: geometry.size.width * max(0, min(1, value)))
                }
            }
            .frame(height: 6)

            Text(String(format: "%3.0f%%", value * 100))
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}
