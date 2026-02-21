import SwiftUI

/// MIDI キーボード画面
struct KeyboardView: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 現在の音色情報
                SoundInfoBar(viewModel: viewModel)

                Spacer()

                // ピアノ鍵盤
                PianoKeyboard(viewModel: viewModel)
                    .padding(.bottom, 20)
            }
            .navigationTitle("キーボード")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sound Info Bar

private struct SoundInfoBar: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("波形")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(viewModel.waveformType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Divider().frame(height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("フィルター")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(viewModel.filterType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Divider().frame(height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("プリセット")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(viewModel.selectedPreset?.name ?? "カスタム")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Spacer()

            // アクティブノート数
            HStack(spacing: 4) {
                Image(systemName: "music.note")
                    .font(.caption2)
                Text("\(viewModel.audioEngine.activeNotes.count)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            .foregroundStyle(.indigo)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Piano Keyboard

private struct PianoKeyboard: View {
    let viewModel: SynthLabViewModel

    // C4 (60) から C6 (84) まで = 2オクターブ
    private let startNote = 60
    private let endNote = 84

    private var whiteKeys: [Int] {
        (startNote...endNote).filter { !isBlackKey($0) }
    }

    var body: some View {
        GeometryReader { geometry in
            let whiteKeyWidth = geometry.size.width / CGFloat(whiteKeys.count)
            let whiteKeyHeight = geometry.size.height * 0.9
            let blackKeyWidth = whiteKeyWidth * 0.6
            let blackKeyHeight = whiteKeyHeight * 0.6

            ZStack(alignment: .top) {
                // 白鍵
                HStack(spacing: 1) {
                    ForEach(whiteKeys, id: \.self) { note in
                        PianoKey(
                            note: note,
                            isBlack: false,
                            isActive: viewModel.audioEngine.activeNotes.contains(note),
                            width: whiteKeyWidth - 1,
                            height: whiteKeyHeight
                        ) {
                            viewModel.noteOn(note)
                        } onRelease: {
                            viewModel.noteOff(note)
                        }
                    }
                }

                // 黒鍵
                HStack(spacing: 0) {
                    ForEach(whiteKeys, id: \.self) { note in
                        let blackNote = note + 1
                        if isBlackKey(blackNote) && blackNote <= endNote {
                            PianoKey(
                                note: blackNote,
                                isBlack: true,
                                isActive: viewModel.audioEngine.activeNotes.contains(blackNote),
                                width: blackKeyWidth,
                                height: blackKeyHeight
                            ) {
                                viewModel.noteOn(blackNote)
                            } onRelease: {
                                viewModel.noteOff(blackNote)
                            }
                            .offset(x: (whiteKeyWidth - blackKeyWidth) / 2 + 0.5)
                        }

                        if note != whiteKeys.last {
                            Spacer()
                                .frame(width: max(whiteKeyWidth - blackKeyWidth, 0))
                        }
                    }
                }
            }
        }
        .frame(height: 200)
        .padding(.horizontal, 8)
    }

    private func isBlackKey(_ note: Int) -> Bool {
        let n = note % 12
        return [1, 3, 6, 8, 10].contains(n)
    }
}

private struct PianoKey: View {
    let note: Int
    let isBlack: Bool
    let isActive: Bool
    let width: CGFloat
    let height: CGFloat
    let onPress: () -> Void
    let onRelease: () -> Void

    private var noteName: String {
        let names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = note / 12 - 1
        return "\(names[note % 12])\(octave)"
    }

    var body: some View {
        RoundedRectangle(cornerRadius: isBlack ? 4 : 6)
            .fill(keyColor)
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.2), radius: isBlack ? 2 : 1, y: 2)
            .overlay(alignment: .bottom) {
                if !isBlack {
                    Text(noteName)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 4)
                }
            }
            .onTapGesture {
                onPress()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onRelease()
                }
            }
    }

    private var keyColor: Color {
        if isActive {
            return .indigo
        }
        return isBlack ? .black : .white
    }
}
