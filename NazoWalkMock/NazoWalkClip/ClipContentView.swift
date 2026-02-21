import SwiftUI
import StoreKit

/// App Clip のメイン画面
/// NFC/QR コードからの起動時に該当スポットの謎解きを即座に表示
struct ClipContentView: View {
    @State private var viewModel = ClipViewModel.shared

    var body: some View {
        NavigationStack {
            Group {
                if let spot = viewModel.currentSpot, let puzzle = viewModel.currentPuzzle {
                    ScrollView {
                        VStack(spacing: 20) {
                            if viewModel.showingResult {
                                resultView(puzzle: puzzle, spot: spot)
                            } else {
                                puzzleView(puzzle: puzzle, spot: spot)
                            }
                        }
                        .padding()
                    }
                } else {
                    // スポット未検出（直接起動された場合）
                    ContentUnavailableView(
                        "スポットが見つかりません",
                        systemImage: "mappin.slash",
                        description: Text("NFC タグまたは QR コードをスキャンしてスポットにアクセスしてください")
                    )
                }
            }
            .navigationTitle("NazoWalk")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Puzzle View

    @ViewBuilder
    private func puzzleView(puzzle: Puzzle, spot: PuzzleSpot) -> some View {
        // スポットヘッダー
        VStack(spacing: 8) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(spot.name)
                .font(.headline)

            Text(puzzle.title)
                .font(.title2)
                .fontWeight(.bold)
        }

        // タイマー
        if let remaining = viewModel.remainingTime {
            Text("残り \(remaining / 60):\(String(format: "%02d", remaining % 60))")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(remaining < 30 ? .red : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: .capsule)
        }

        // 問題文
        Text(puzzle.question)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))

        // 選択肢
        ForEach(Array(puzzle.choices.enumerated()), id: \.element.id) { index, choice in
            Button {
                viewModel.selectChoice(index)
            } label: {
                HStack {
                    Text(["A", "B", "C", "D"][index])
                        .fontWeight(.bold)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(viewModel.selectedChoiceIndex == index ? Color.orange : Color.secondary.opacity(0.2))
                        )
                        .foregroundStyle(viewModel.selectedChoiceIndex == index ? .white : .primary)

                    Text(choice.text)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.selectedChoiceIndex == index ? Color.orange : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }

        // ヒント
        if viewModel.showingHint {
            Label(puzzle.hint, systemImage: "lightbulb.fill")
                .font(.caption)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.yellow.opacity(0.1), in: .rect(cornerRadius: 12))
        } else {
            Button("ヒントを見る") { viewModel.showingHint = true }
                .buttonStyle(.bordered)
        }

        // 回答ボタン
        Button("回答する") {
            viewModel.submitAnswer()
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .disabled(viewModel.selectedChoiceIndex == nil)
    }

    // MARK: - Result View

    @ViewBuilder
    private func resultView(puzzle: Puzzle, spot: PuzzleSpot) -> some View {
        VStack(spacing: 16) {
            if viewModel.isPuzzleSolved {
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))

            // 次のヒント
            if let hint = spot.nextHint, viewModel.isPuzzleSolved {
                VStack(alignment: .leading, spacing: 4) {
                    Label("次のスポットへのヒント", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Text(hint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.orange.opacity(0.1), in: .rect(cornerRadius: 12))
            }

            // フルアプリへの誘導
            AppStoreOverlayModifier()
        }
    }
}

/// SKOverlay でフルアプリを促す修飾子
private struct AppStoreOverlayModifier: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("フルアプリで全スポットを楽しもう!")
                .font(.headline)
            Text("ランキング、過去のイベント、オリジナル謎作成")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }
}
