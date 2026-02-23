import SwiftUI

struct ResultView: View {
    var viewModel: ARShadowViewModel
    let result: GameResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Star display
                starDisplay

                // Score
                VStack(spacing: 8) {
                    Text("一致度")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("\(result.score)%")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                }

                // Details
                detailsCard

                // Feedback
                feedbackText

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    Button {
                        dismiss()
                        viewModel.startGame()
                    } label: {
                        Label("もう一度", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        dismiss()
                        viewModel.returnToStageSelect()
                    } label: {
                        Text("ステージ選択に戻る")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("結果")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Star Display

    private var starDisplay: some View {
        HStack(spacing: 16) {
            ForEach(1...3, id: \.self) { star in
                Image(systemName: star <= result.stage.starRating ? "star.fill" : "star")
                    .font(.system(size: 40))
                    .foregroundStyle(star <= result.stage.starRating ? .yellow : .gray.opacity(0.3))
            }
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Image(systemName: "timer")
                    .foregroundStyle(.blue)
                Text(formatTime(result.timeElapsed))
                    .font(.headline)
                Text("経過時間")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Image(systemName: result.stage.targetShape.systemImage)
                    .foregroundStyle(result.stage.targetShape.color)
                Text(result.stage.targetShape.rawValue)
                    .font(.headline)
                Text("ターゲット")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Image(systemName: result.stage.difficulty.systemImage)
                    .foregroundStyle(result.stage.difficulty.color)
                Text(result.stage.difficulty.rawValue)
                    .font(.headline)
                Text("難易度")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Feedback

    private var feedbackText: some View {
        Text(feedback)
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    private var feedback: String {
        if result.score >= 95 {
            return "完璧な影絵です！光と影のマスターですね"
        } else if result.score >= 80 {
            return "素晴らしい出来栄えです！細部の調整でさらに高得点を狙えます"
        } else if result.score >= 60 {
            return "良い感じです。物体の配置と光源の角度を工夫してみましょう"
        } else {
            return "影の形を目標に近づけるには、光源の位置と物体の組み合わせがポイントです"
        }
    }

    // MARK: - Helpers

    private var scoreColor: Color {
        if result.score >= 80 { return .green }
        if result.score >= 60 { return .orange }
        return .red
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ResultView(
        viewModel: ARShadowViewModel(),
        result: GameResult(
            stage: PuzzleStage.samples[0],
            accuracy: 0.85,
            timeElapsed: 45
        )
    )
}
