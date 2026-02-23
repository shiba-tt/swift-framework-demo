import SwiftUI

struct ProjectDetailView: View {
    let project: ReelProject
    @Bindable var viewModel: ReelForgeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    previewSection
                    timelineSection
                    bgmSection
                    statsSection
                    techStackSection
                    actionSection
                }
                .padding()
            }
            .navigationTitle(project.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.selectedProject = nil
                    }
                }
            }
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)

                VStack(spacing: 12) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                    Text(project.title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text(project.totalDurationText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            HStack(spacing: 16) {
                Label(project.status.rawValue, systemImage: "circle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(project.status.color)

                Label(project.targetDuration.rawValue, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(project.transitionStyle.rawValue, systemImage: "arrow.triangle.swap")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("タイムライン", systemImage: "timeline.selection")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(project.selectedClips) { clip in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(clip.sceneCategory.color.opacity(0.3))
                                .frame(width: max(40, CGFloat(clip.trimmedDuration) * 8), height: 50)
                                .overlay {
                                    VStack(spacing: 2) {
                                        Text(clip.sceneCategory.emoji)
                                            .font(.caption)
                                        Text(clip.durationText)
                                            .font(.system(size: 8))
                                    }
                                }

                            Text(clip.sceneCategory.rawValue)
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // BGM waveform mock
            HStack(spacing: 1) {
                ForEach(0..<60, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.purple.opacity(0.5))
                        .frame(width: 3, height: CGFloat.random(in: 5...25))
                }
            }
            .frame(height: 25)

            HStack {
                Image(systemName: "music.note")
                    .foregroundStyle(.purple)
                Text(project.bgmTrack.name)
                    .font(.caption)
                Spacer()
                Text(project.bgmTrack.bpmText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - BGM

    private var bgmSection: some View {
        HStack {
            Text(project.bgmTrack.genre.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(project.bgmTrack.genre.color.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text(project.bgmTrack.name)
                    .font(.subheadline.bold())
                Text("\(project.bgmTrack.artist) — \(project.bgmTrack.genre.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(project.bgmTrack.bpmText)
                    .font(.caption.bold())
                Text(project.bgmTrack.durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI 分析結果", systemImage: "chart.bar")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard("クリップ数", value: "\(project.clipCount)", icon: "film", color: .blue)
                statCard("総尺", value: project.totalDurationText, icon: "clock", color: .green)
                statCard("平均スコア", value: String(format: "%.0f%%", project.averageScore * 100), icon: "star.fill", color: .orange)
                statCard("トランジション", value: project.transitionStyle.rawValue, icon: "arrow.triangle.swap", color: .purple)
            }
        }
    }

    private func statCard(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Tech Stack

    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("技術スタック", systemImage: "cpu")
                .font(.headline)

            let techs = [
                ("Photos Framework", "カメラロールから素材取得"),
                ("Vision", "顔検出（笑顔スコア）・シーン分類"),
                ("Core ML", "映えスコアリング・安定度判定"),
                ("AVComposition", "クリップ結合・トリミング・速度変更"),
                ("AVVideoComposition", "テロップ・ウォーターマーク合成"),
                ("AVAssetExportSession", "H.264/HEVC 書き出し"),
                ("AVAudioEngine", "BGM ビート解析・カットタイミング計算"),
            ]

            ForEach(techs, id: \.0) { tech in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .font(.caption)
                        .foregroundStyle(.purple)
                        .frame(width: 16)
                    VStack(alignment: .leading) {
                        Text(tech.0)
                            .font(.caption.bold())
                        Text(tech.1)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private var actionSection: some View {
        VStack(spacing: 12) {
            Button {
                // Mock export
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("SNS に共有")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
            }

            HStack(spacing: 12) {
                Button {
                    // Mock re-generate
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("再生成")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    // Mock edit
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("編集")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
