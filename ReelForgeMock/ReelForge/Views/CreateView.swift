import SwiftUI

struct CreateView: View {
    @Bindable var viewModel: ReelForgeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    clipSelectionSection
                    settingsSection
                    generateButton
                }
                .padding()
            }
            .navigationTitle("ReelForge")
            .sheet(isPresented: $viewModel.showBGMPicker) {
                bgmPickerSheet
            }
            .sheet(isPresented: $viewModel.showGenerationSheet) {
                GenerationProgressView(viewModel: viewModel)
                    .interactiveDismissDisabled(viewModel.isProcessing)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.purple)
                Text("AI ショートムービー")
                    .font(.title2.bold())
                Spacer()
            }

            Text("素材を選んでAIが自動で映えるリールを生成します。笑顔シーン優先・ビート同期カット・テロップ自動配置に対応。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Clip Selection

    private var clipSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("素材を選択", systemImage: "photo.stack")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.selectedClipCount)件選択 / \(viewModel.totalSelectedDurationText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.clips) { clip in
                    clipCard(clip)
                }
            }
        }
    }

    private func clipCard(_ clip: MediaClip) -> some View {
        Button {
            viewModel.toggleClipSelection(clip)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(clip.sceneCategory.color.opacity(0.2))
                        .frame(height: 80)
                        .overlay {
                            VStack {
                                Text(clip.sceneCategory.emoji)
                                    .font(.title)
                                Text(clip.type.emoji + " " + clip.durationText)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                    if clip.isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.purple)
                            .background(Circle().fill(.white).padding(2))
                            .padding(6)
                    }
                }

                HStack(spacing: 4) {
                    Text(clip.sceneCategory.rawValue)
                        .font(.caption.bold())

                    Spacer()

                    HStack(spacing: 2) {
                        Image(systemName: "face.smiling")
                            .font(.caption2)
                        Text(String(format: "%.0f%%", clip.smileScore * 100))
                            .font(.caption2)
                    }
                    .foregroundStyle(clip.scoreColor)
                }

                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: Double(i) < clip.overallScore * 5 ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(8)
            .background(clip.isSelected ? Color.purple.opacity(0.08) : Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(clip.isSelected ? Color.purple : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("生成設定", systemImage: "slider.horizontal.3")
                .font(.headline)

            // Title
            VStack(alignment: .leading, spacing: 6) {
                Text("タイトル")
                    .font(.subheadline.bold())
                TextField("夏の思い出 2026", text: $viewModel.projectTitle)
                    .textFieldStyle(.roundedBorder)
            }

            // BGM
            VStack(alignment: .leading, spacing: 6) {
                Text("BGM")
                    .font(.subheadline.bold())
                Button {
                    viewModel.showBGMPicker = true
                } label: {
                    HStack {
                        if let bgm = viewModel.selectedBGM {
                            Text(bgm.genre.emoji)
                            VStack(alignment: .leading) {
                                Text(bgm.name)
                                    .font(.subheadline.bold())
                                Text("\(bgm.artist) — \(bgm.bpmText)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Image(systemName: "music.note")
                            Text("BGMを選択")
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }

            // Duration
            VStack(alignment: .leading, spacing: 6) {
                Text("ターゲット尺")
                    .font(.subheadline.bold())
                Picker("ターゲット尺", selection: $viewModel.selectedDuration) {
                    ForEach(TargetDuration.allCases) { duration in
                        Text(duration.label).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Transition
            VStack(alignment: .leading, spacing: 6) {
                Text("トランジション")
                    .font(.subheadline.bold())
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TransitionStyle.allCases) { style in
                            Button {
                                viewModel.selectedTransition = style
                            } label: {
                                VStack(spacing: 4) {
                                    Text(style.emoji)
                                        .font(.title3)
                                    Text(style.rawValue)
                                        .font(.caption2)
                                }
                                .frame(width: 70, height: 56)
                                .background(
                                    viewModel.selectedTransition == style
                                        ? Color.purple.opacity(0.15)
                                        : Color(.systemGray6),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.selectedTransition == style ? Color.purple : .clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            viewModel.startGeneration()
        } label: {
            HStack {
                Image(systemName: "wand.and.stars")
                Text("AI リールを生成")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canGenerate ? Color.purple : Color.gray, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
        }
        .disabled(!viewModel.canGenerate)
    }

    // MARK: - BGM Picker Sheet

    private var bgmPickerSheet: some View {
        NavigationStack {
            List(viewModel.availableBGMs) { bgm in
                Button {
                    viewModel.selectBGM(bgm)
                } label: {
                    HStack {
                        Text(bgm.genre.emoji)
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(bgm.genre.color.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading) {
                            Text(bgm.name)
                                .font(.headline)
                            Text("\(bgm.artist) — \(bgm.genre.rawValue) — \(bgm.bpmText)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(bgm.durationText)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if viewModel.selectedBGM?.id == bgm.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.purple)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("BGM を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.showBGMPicker = false
                    }
                }
            }
        }
    }
}
