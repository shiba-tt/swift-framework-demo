import SwiftUI

struct CommandHistoryView: View {
    @Bindable var viewModel: VoiceRecipeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dynamicIslandPreview
                    commandLogSection
                    techStackSection
                }
                .padding()
            }
            .navigationTitle("履歴・情報")
        }
    }

    // MARK: - Dynamic Island Preview

    private var dynamicIslandPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Dynamic Island プレビュー")
                    .font(.headline)
                Image(systemName: "island.fill")
                    .foregroundStyle(.orange)
            }

            if let session = viewModel.activeSession {
                // Dynamic Island 風の表示
                HStack(spacing: 12) {
                    Image(systemName: session.recipe.imageSystemName)
                        .font(.title3)
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.recipe.name)
                            .font(.caption.bold())
                        Text("ステップ \(session.currentStepIndex + 1)/\(session.recipe.steps.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let timerText = session.timerRemainingText, session.isTimerRunning {
                        Text(timerText)
                            .font(.system(.body, design: .rounded).bold().monospacedDigit())
                            .foregroundStyle(.orange)
                    }
                }
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            } else {
                Text("調理中にレシピの進行状況とタイマーが表示されます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Command Log

    private var commandLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundStyle(.orange)
                Text("音声コマンド履歴")
                    .font(.headline)
            }

            if viewModel.recentCommands.isEmpty {
                Text("調理を開始すると音声コマンドの履歴がここに表示されます")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(viewModel.recentCommands.prefix(10)) { command in
                    commandRow(command)
                }
            }
        }
    }

    private func commandRow(_ command: VoiceCommand) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "mic.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text(command.command)
                    .font(.subheadline.bold())
                Spacer()
                Text(command.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            HStack(alignment: .top) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(command.response)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(command.type.rawValue)
                    .font(.system(size: 10))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.orange.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Tech Stack

    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用フレームワーク")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                techItem("App Intents", detail: "各操作（次のステップ、タイマー等）を Intent として定義、Siri から実行")
                techItem("Live Activity", detail: "現在のステップとタイマーをロック画面・Dynamic Island に常時表示")
                techItem("LiveActivityIntent", detail: "アプリを開かず Live Activity 上のボタンでステップ操作")
                techItem("Interactive Widget", detail: "次のステップへの進行ボタンと現在の工程写真を表示")
                techItem("UndoableIntent", detail: "「前のステップに戻って」で操作の取り消しに対応")
                techItem("App Shortcuts", detail: "「Hey Siri、次のステップ」で即座にアクション実行")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func techItem(_ name: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.orange)
                .frame(width: 12)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    CommandHistoryView(viewModel: VoiceRecipeViewModel())
}
