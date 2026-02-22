import SwiftUI

struct StudyView: View {
    @Bindable var viewModel: FlashCardViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isStudying {
                    studySessionView()
                } else {
                    studyMenuView()
                }
            }
            .navigationTitle("学習")
        }
    }

    // MARK: - Study Menu

    private func studyMenuView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.totalDueCards > 0 {
                    allDueSection()
                } else {
                    completedSection()
                }

                deckStudySection()
            }
            .padding()
        }
    }

    private func allDueSection() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("復習カードが \(viewModel.totalDueCards)枚 あります")
                .font(.title3)
                .fontWeight(.semibold)

            Text("間隔反復アルゴリズムにより、最適なタイミングで出題されます")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.startStudy()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("全デッキの復習を開始")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(.blue, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func completedSection() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("お疲れ様でした！")
                .font(.title3)
                .fontWeight(.semibold)

            Text("今日の復習はすべて完了しています。\n明日また新しいカードが復習対象になります。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func deckStudySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("デッキ別学習")
                .font(.headline)

            ForEach(viewModel.decks) { deck in
                deckStudyRow(deck)
            }
        }
    }

    private func deckStudyRow(_ deck: Deck) -> some View {
        HStack {
            Image(systemName: deck.category.icon)
                .foregroundStyle(deck.category.color)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(deck.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("復習: \(deck.dueCards)枚 / 全\(deck.totalCards)枚")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if deck.dueCards > 0 {
                Button {
                    viewModel.startStudy(deckId: deck.id)
                } label: {
                    Text("開始")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(.white)
                        .background(.blue, in: Capsule())
                }
            } else {
                Text("完了")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding(12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Study Session

    private func studySessionView() -> some View {
        VStack(spacing: 0) {
            progressBar()

            if let card = viewModel.currentCard {
                cardView(card)
                    .padding()

                Spacer()

                if viewModel.isCardFlipped {
                    answerButtons()
                } else {
                    flipButton()
                }
            } else {
                sessionCompleteView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("終了") {
                    viewModel.endStudy()
                }
            }
        }
    }

    private func progressBar() -> some View {
        VStack(spacing: 4) {
            ProgressView(value: viewModel.studyProgress)
                .tint(.blue)

            HStack {
                Text("\(viewModel.currentCardIndex) / \(viewModel.currentStudyCards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func cardView(_ card: FlashCard) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: card.difficulty.icon)
                    .foregroundStyle(card.difficulty.color)
                Text(card.difficulty.displayName)
                    .font(.caption)
                    .foregroundStyle(card.difficulty.color)
                Spacer()
                Text(card.masteryLevel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.isCardFlipped {
                VStack(spacing: 12) {
                    Text("A")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text(card.back)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 12) {
                    Text("Q")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text(card.front)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: 350)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            viewModel.flipCard()
        }
    }

    private func flipButton() -> some View {
        Button {
            viewModel.flipCard()
        } label: {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("タップで答えを表示")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }

    private func answerButtons() -> some View {
        HStack(spacing: 16) {
            Button {
                viewModel.answerCard(isCorrect: false)
            } label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("知らない")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(.red, in: RoundedRectangle(cornerRadius: 12))
            }

            Button {
                viewModel.answerCard(isCorrect: true)
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("知ってる")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(.green, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }

    private func sessionCompleteView() -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "party.popper.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)

            Text("セッション完了！")
                .font(.title2)
                .fontWeight(.bold)

            Text("全カードの復習が終わりました")
                .foregroundStyle(.secondary)

            Button {
                viewModel.endStudy()
            } label: {
                Text("ホームに戻る")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}
