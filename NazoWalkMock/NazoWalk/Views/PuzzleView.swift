import SwiftUI

/// 謎解きパズル画面
struct PuzzleView: View {
    @Bindable var viewModel: AdventureViewModel
    let spot: PuzzleSpot
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let puzzle = viewModel.currentPuzzle {
                        if viewModel.showingResult {
                            resultSection(puzzle)
                        } else {
                            puzzleSection(puzzle)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(spot.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - Puzzle Section

    @ViewBuilder
    private func puzzleSection(_ puzzle: Puzzle) -> some View {
        // スポット情報
        VStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text(puzzle.title)
                .font(.title2)
                .fontWeight(.bold)

            Text("スポット \(spot.order)/\(viewModel.spots.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        // タイマー（制限時間あり）
        if let remaining = viewModel.remainingTime {
            HStack {
                Image(systemName: "timer")
                Text("残り \(remaining / 60):\(String(format: "%02d", remaining % 60))")
                    .monospacedDigit()
            }
            .font(.headline)
            .foregroundStyle(remaining < 30 ? .red : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: .capsule)
        }

        // 問題文
        VStack(alignment: .leading, spacing: 8) {
            Text("問題")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            Text(puzzle.question)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))

        // 選択肢
        VStack(spacing: 8) {
            ForEach(Array(puzzle.choices.enumerated()), id: \.element.id) { index, choice in
                Button {
                    viewModel.selectChoice(index)
                } label: {
                    HStack {
                        Text(["A", "B", "C", "D"][index])
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(viewModel.selectedChoiceIndex == index ? Color.orange : Color.secondary.opacity(0.2))
                            )
                            .foregroundStyle(viewModel.selectedChoiceIndex == index ? .white : .primary)

                        Text(choice.text)
                            .font(.subheadline)

                        Spacer()

                        if viewModel.selectedChoiceIndex == index {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.selectedChoiceIndex == index ? Color.orange : Color.secondary.opacity(0.3), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }

        // ヒントボタン
        if !viewModel.showingHint {
            Button {
                viewModel.showingHint = true
            } label: {
                Label("ヒントを見る", systemImage: "lightbulb")
            }
            .buttonStyle(.bordered)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Label("ヒント", systemImage: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                Text(puzzle.hint)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.yellow.opacity(0.1), in: .rect(cornerRadius: 12))
        }

        // 回答ボタン
        Button {
            viewModel.submitAnswer()
        } label: {
            Text("回答する")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .disabled(viewModel.selectedChoiceIndex == nil)
    }

    // MARK: - Result Section

    @ViewBuilder
    private func resultSection(_ puzzle: Puzzle) -> some View {
        VStack(spacing: 16) {
            if viewModel.isPuzzleSolved {
                // 正解
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)

                Text("正解!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("+\(puzzle.points) ポイント")
                    .font(.title3)
                    .foregroundStyle(.orange)
            } else {
                // 不正解
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.red)

                Text("不正解...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            // 解説
            VStack(alignment: .leading, spacing: 8) {
                Text("解説")
                    .font(.headline)
                Text(puzzle.explanation)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))

            // 次のスポットへのヒント
            if let nextHint = spot.nextHint, viewModel.isPuzzleSolved {
                VStack(alignment: .leading, spacing: 8) {
                    Label("次のスポットへのヒント", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Text(nextHint)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.orange.opacity(0.1), in: .rect(cornerRadius: 12))
            }

            // アクションボタン
            Button {
                viewModel.moveToNextSpot()
                dismiss()
            } label: {
                if viewModel.isAllCleared {
                    Label("結果を見る", systemImage: "trophy.fill")
                } else if viewModel.isPuzzleSolved {
                    Label("次のスポットへ", systemImage: "arrow.right")
                } else {
                    Label("もう一度挑戦", systemImage: "arrow.counterclockwise")
                }
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
}
