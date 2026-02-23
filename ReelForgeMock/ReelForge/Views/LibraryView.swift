import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: ReelForgeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summarySection
                    categoryBreakdown
                    allClipsSection
                    techInfoSection
                }
                .padding()
            }
            .navigationTitle("ライブラリ")
        }
    }

    // MARK: - Summary

    private var summarySection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            summaryCard(
                "総素材",
                value: "\(viewModel.clips.count)",
                icon: "photo.on.rectangle.angled",
                color: .blue
            )
            summaryCard(
                "動画",
                value: "\(viewModel.clips.filter { $0.type == .video }.count)",
                icon: "video.fill",
                color: .purple
            )
            summaryCard(
                "写真",
                value: "\(viewModel.clips.filter { $0.type == .photo }.count)",
                icon: "photo.fill",
                color: .orange
            )
        }
    }

    private func summaryCard(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("シーン分類", systemImage: "tag")
                .font(.headline)

            ForEach(viewModel.sceneCategorySummary, id: \.0) { category, count in
                HStack {
                    Text(category.emoji)
                    Text(category.rawValue)
                        .font(.subheadline)

                    Spacer()

                    GeometryReader { geo in
                        let maxCount = viewModel.sceneCategorySummary.first?.1 ?? 1
                        let width = geo.size.width * CGFloat(count) / CGFloat(maxCount)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(category.color.opacity(0.6))
                            .frame(width: max(width, 4), height: 16)
                    }
                    .frame(width: 100, height: 16)

                    Text("\(count)件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - All Clips

    private var allClipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("全素材一覧", systemImage: "list.bullet")
                .font(.headline)

            ForEach(viewModel.clips) { clip in
                clipRow(clip)
            }
        }
    }

    private func clipRow(_ clip: MediaClip) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(clip.sceneCategory.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                Text(clip.sceneCategory.emoji)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(clip.type.emoji + " " + clip.sceneCategory.rawValue)
                        .font(.subheadline.bold())
                    Spacer()
                    Text(clip.durationText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    HStack(spacing: 2) {
                        Image(systemName: "face.smiling")
                            .font(.caption2)
                        Text(String(format: "%.0f%%", clip.smileScore * 100))
                            .font(.caption2)
                    }

                    HStack(spacing: 2) {
                        Image(systemName: "gyroscope")
                            .font(.caption2)
                        Text(String(format: "%.0f%%", clip.stabilityScore * 100))
                            .font(.caption2)
                    }

                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text(String(format: "%.0f", clip.overallScore * 100))
                            .font(.caption2)
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Tech Info

    private var techInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("AI 解析パイプライン", systemImage: "brain")
                .font(.headline)

            Text("各素材に対して以下の AI 解析を実行し、ベストショットを自動選出します:")
                .font(.caption)
                .foregroundStyle(.secondary)

            let pipeline = [
                ("Vision — 顔検出", "笑顔シーンを優先。VNDetectFaceLandmarksRequest で笑顔スコアを算出"),
                ("Core ML — シーン分類", "景色 / 食事 / 人物 / 動物 等をカスタムモデルで分類"),
                ("AVAsset — 安定性解析", "手ブレの少ない安定シーンを優先選出"),
                ("SoundAnalysis — 音声解析", "笑い声・歓声シーンをハイライト検出"),
                ("AVAudioEngine — ビート解析", "BGM のビートタイミングに合わせてカット位置を最適化"),
            ]

            ForEach(pipeline, id: \.0) { step in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 6, height: 6)
                        .padding(.top, 5)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.0)
                            .font(.caption.bold())
                        Text(step.1)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}
