import SwiftUI

// MARK: - SetlistView（セットリスト画面）

struct SetlistView: View {
    @Bindable var viewModel: PedalBoardViewModel
    @State private var showingNewSetlist = false
    @State private var newSetlistName = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.setlists.isEmpty {
                    emptyState
                } else {
                    setlistContent
                }
            }
            .navigationTitle("セットリスト")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewSetlist = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .alert("新しいセットリスト", isPresented: $showingNewSetlist) {
                TextField("セットリスト名", text: $newSetlistName)
                Button("作成") {
                    viewModel.createSetlist(name: newSetlistName)
                    newSetlistName = ""
                }
                Button("キャンセル", role: .cancel) {
                    newSetlistName = ""
                }
            } message: {
                Text("ライブで使用するセットリストの名前を入力してください")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(.orange.opacity(0.5))

            Text("セットリストがありません")
                .font(.title2)
                .fontWeight(.semibold)

            Text("ライブやリハーサルで使う曲順と\nプリセットをセットリストで管理しましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewSetlist = true
            } label: {
                Label("セットリストを作成", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    // MARK: - Setlist Content

    private var setlistContent: some View {
        List {
            ForEach(viewModel.setlists) { setlist in
                Section {
                    ForEach(setlist.songs) { song in
                        SetlistSongRow(
                            song: song,
                            preset: viewModel.presets.first { $0.id == song.presetID }
                        )
                    }

                    // 曲追加ボタン
                    Button {
                        // 曲追加のUIは簡略化
                        if let firstPreset = viewModel.presets.first {
                            viewModel.addSongToSetlist(
                                setlistID: setlist.id,
                                title: "新しい曲",
                                presetID: firstPreset.id,
                                bpm: 120
                            )
                        }
                    } label: {
                        Label("曲を追加", systemImage: "plus")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                } header: {
                    HStack {
                        Text(setlist.name)
                        Spacer()
                        Text("\(setlist.songs.count) 曲")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - SetlistSongRow

struct SetlistSongRow: View {
    let song: SetlistSong
    let preset: PedalBoardPreset?

    var body: some View {
        HStack(spacing: 12) {
            // 曲順
            Text("\(song.order + 1)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    if let preset {
                        Label(preset.name, systemImage: "slider.horizontal.3")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }

                    if let bpm = song.bpm {
                        Label("\(bpm) BPM", systemImage: "metronome")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // プリセット読み込みボタン
            if let preset {
                Button {
                    // プリセット読み込み
                } label: {
                    Text(preset.category.emoji)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - TunerView（チューナー画面）

struct TunerView: View {
    @Bindable var viewModel: PedalBoardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // 音名表示
                Text(viewModel.tunerData.noteWithOctave)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(viewModel.tunerData.tuningStatus.colorName))

                // チューニングメーター
                tuningMeter

                // 周波数表示
                Text(String(format: "%.1f Hz", viewModel.tunerData.frequency))
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                // セント表示
                Text(String(format: "%+.0f cents", viewModel.tunerData.centsOff))
                    .font(.subheadline)
                    .foregroundStyle(Color(viewModel.tunerData.tuningStatus.colorName))

                // ステータス
                Text(viewModel.tunerData.tuningStatus.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(viewModel.tunerData.tuningStatus.colorName))

                Spacer()
            }
            .padding()
            .navigationTitle("チューナー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        viewModel.toggleTuner()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Tuning Meter

    private var tuningMeter: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let center = width / 2
            let offset = CGFloat(viewModel.tunerData.centsOff / 50) * (width / 2 - 20)

            ZStack {
                // 目盛り
                ForEach(-5..<6, id: \.self) { i in
                    Rectangle()
                        .fill(i == 0 ? .green : .gray.opacity(0.3))
                        .frame(width: i == 0 ? 2 : 1, height: i == 0 ? 30 : 20)
                        .position(x: center + CGFloat(i) * (width / 12), y: 20)
                }

                // インジケーター
                if viewModel.tunerData.frequency > 0 {
                    Triangle()
                        .fill(Color(viewModel.tunerData.tuningStatus.colorName))
                        .frame(width: 16, height: 12)
                        .position(x: center + offset, y: 42)
                }
            }
        }
        .frame(height: 56)
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
