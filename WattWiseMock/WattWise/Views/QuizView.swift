import SwiftUI

/// 子供向けエネルギークイズ画面
struct QuizView: View {
    @Bindable var viewModel: WattWiseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    quizHeader
                    if let quiz = viewModel.currentQuiz {
                        quizCard(quiz)
                        if viewModel.showQuizResult {
                            resultCard(quiz)
                        }
                    }
                    scoreBoard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("エネルギークイズ")
        }
    }

    // MARK: - ヘッダー

    private var quizHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            Text("エネルギーについて学ぼう!")
                .font(.title3)
                .fontWeight(.bold)
            Text("クイズに正解してポイントを貯めよう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - クイズカード

    private func quizCard(_ quiz: EnergyQuiz) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.orange)
                Text("Q.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }

            Text(quiz.question)
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(Array(quiz.options.enumerated()), id: \.offset) { index, option in
                    optionButton(index: index, text: option, quiz: quiz)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func optionButton(index: Int, text: String, quiz: EnergyQuiz) -> some View {
        Button {
            if !viewModel.showQuizResult {
                viewModel.answerQuiz(index)
            }
        } label: {
            HStack {
                Text(optionLabel(index))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(optionColor(index: index, quiz: quiz), in: Circle())

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                if viewModel.showQuizResult && index == quiz.correctIndex {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if viewModel.showQuizResult && index == viewModel.selectedQuizAnswer && index != quiz.correctIndex {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(
                optionBackground(index: index, quiz: quiz),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .disabled(viewModel.showQuizResult)
    }

    // MARK: - 結果カード

    private func resultCard(_ quiz: EnergyQuiz) -> some View {
        VStack(spacing: 16) {
            let isCorrect = viewModel.selectedQuizAnswer == quiz.correctIndex

            Image(systemName: isCorrect ? "party.popper.fill" : "lightbulb.fill")
                .font(.system(size: 36))
                .foregroundStyle(isCorrect ? .yellow : .orange)

            Text(isCorrect ? "正解!" : "残念...")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(isCorrect ? .green : .orange)

            Text(quiz.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if isCorrect {
                Text("+\(quiz.points) pt 獲得!")
                    .font(.headline)
                    .foregroundStyle(.green)
            }

            Button {
                viewModel.nextQuiz()
            } label: {
                Label("次の問題", systemImage: "arrow.right")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.green, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - スコアボード

    private var scoreBoard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("スコアボード", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundStyle(.yellow)

            let children = viewModel.familyMembers.filter { $0.role == .child }
                .sorted { $0.quizScore > $1.quizScore }

            ForEach(Array(children.enumerated()), id: \.element.id) { index, member in
                HStack {
                    Text(index == 0 ? "🥇" : "🥈")
                        .font(.title2)
                    Text(member.icon)
                        .font(.title2)
                    Text(member.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(member.quizScore) pt")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - ヘルパー

    private func optionLabel(_ index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }

    private func optionColor(index: Int, quiz: EnergyQuiz) -> Color {
        guard viewModel.showQuizResult else { return .gray }
        if index == quiz.correctIndex { return .green }
        if index == viewModel.selectedQuizAnswer { return .red }
        return .gray
    }

    private func optionBackground(index: Int, quiz: EnergyQuiz) -> Color {
        guard viewModel.showQuizResult else { return Color(.tertiarySystemFill) }
        if index == quiz.correctIndex { return .green.opacity(0.1) }
        if index == viewModel.selectedQuizAnswer && index != quiz.correctIndex {
            return .red.opacity(0.1)
        }
        return Color(.tertiarySystemFill)
    }
}
