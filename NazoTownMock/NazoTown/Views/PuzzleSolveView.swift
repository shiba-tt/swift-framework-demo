import SwiftUI

struct PuzzleSolveView: View {
    @Bindable var viewModel: NazoTownViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let adventure = viewModel.activeAdventure,
                   adventure.status == .completed {
                    completionView
                } else if let spot = viewModel.selectedSpot {
                    puzzleContent(spot)
                } else {
                    ContentUnavailableView(
                        "スポットを探そう",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("NFCタグをスキャンして次のパズルを見つけてください")
                    )
                }
            }
            .navigationTitle("謎解き")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Label(viewModel.remainingTimeText, systemImage: "clock")
                            .font(.caption.monospacedDigit())

                        Label(viewModel.progressText, systemImage: "checkmark.circle")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $viewModel.showingResult) {
                resultSheet
            }
        }
    }

    // MARK: - Puzzle Content

    private func puzzleContent(_ spot: PuzzleSpot) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                spotHeader(spot)
                puzzleCard(spot.puzzle)
                choicesSection(spot.puzzle)

                if viewModel.isShowingHint {
                    hintCard(spot.puzzle)
                }

                actionButtons
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Spot Header

    private func spotHeader(_ spot: PuzzleSpot) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.indigo)

            VStack(alignment: .leading, spacing: 2) {
                Text("スポット \(spot.spotNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(spot.name)
                    .font(.headline)
            }

            Spacer()

            difficultyStars(spot.puzzle.difficulty)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func difficultyStars(_ difficulty: PuzzleDifficulty) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Image(systemName: index < difficulty.stars ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(difficulty.color)
            }
        }
    }

    // MARK: - Puzzle Card

    private func puzzleCard(_ puzzle: Puzzle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: puzzle.type.icon)
                    .foregroundStyle(puzzle.type.color)

                Text(puzzle.type.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(puzzle.type.color)
            }

            Text(puzzle.question)
                .font(.body)
                .lineSpacing(4)

            HStack {
                Image(systemName: "timer")
                    .font(.caption)
                Text("経過時間: \(formattedTime(viewModel.elapsedTime))")
                    .font(.caption.monospacedDigit())
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(puzzle.type.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Choices

    private func choicesSection(_ puzzle: Puzzle) -> some View {
        VStack(spacing: 10) {
            Text("回答を選択")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(puzzle.choices, id: \.self) { choice in
                Button {
                    viewModel.selectAnswer(choice)
                } label: {
                    HStack {
                        Image(systemName: viewModel.selectedAnswer == choice
                              ? "checkmark.circle.fill"
                              : "circle")

                        Text(choice)
                            .font(.body)

                        Spacer()
                    }
                    .padding()
                    .background(
                        viewModel.selectedAnswer == choice
                            ? Color.indigo.opacity(0.1)
                            : Color(.secondarySystemGroupedBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.selectedAnswer == choice ? .indigo : .clear,
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Hint

    private func hintCard(_ puzzle: Puzzle) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)

            Text(puzzle.hint)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.submitAnswer()
            } label: {
                Text("回答する")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedAnswer != nil ? .indigo : .gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.selectedAnswer == nil)

            Button {
                viewModel.toggleHint()
            } label: {
                Label(
                    viewModel.isShowingHint ? "ヒントを隠す" : "ヒントを見る",
                    systemImage: "lightbulb"
                )
                .font(.subheadline)
                .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - Result Sheet

    private var resultSheet: some View {
        VStack(spacing: 24) {
            if let result = viewModel.lastResult {
                Image(systemName: result.isSolved ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(result.isSolved ? .green : .red)

                Text(result.isSolved ? "正解！" : "不正解...")
                    .font(.title.bold())

                VStack(spacing: 8) {
                    statRow("獲得ポイント", value: "\(result.scorePoints) pt")
                    statRow("回答時間", value: formattedTime(result.timeSpent))
                    statRow("ヒント使用", value: result.hintUsed ? "あり" : "なし")
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    viewModel.proceedToNextSpot()
                } label: {
                    Text(viewModel.activeAdventure?.status == .completed
                         ? "結果を見る" : "次のスポットへ")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(24)
        .presentationDetents([.medium])
    }

    // MARK: - Completion View

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let stats = viewModel.completionStats {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.yellow)

                    Text("冒険完了！")
                        .font(.largeTitle.bold())

                    Text("ランク: \(stats.rank)")
                        .font(.title)
                        .foregroundStyle(.indigo)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(.indigo.opacity(0.1))
                        .clipShape(Capsule())

                    VStack(spacing: 12) {
                        statRow("合計スコア", value: "\(stats.totalScore) pt")
                        statRow("正解数", value: "\(stats.solvedCount) / \(stats.totalSpots)")
                        statRow("正答率", value: String(format: "%.0f%%", stats.accuracy))
                        statRow("合計時間", value: formattedTime(stats.totalTime))
                        statRow("ヒント使用", value: "\(stats.hintsUsed) 回")
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        viewModel.resetAdventure()
                    } label: {
                        Text("冒険リストに戻る")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Helpers

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body.bold())
        }
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
