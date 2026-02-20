import SwiftUI

/// ポモドーロタイマーのメイン画面
struct TimerView: View {
    @Bindable var viewModel: PomodoroViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // フェーズインジケーター
                PhaseIndicator(
                    currentPhase: viewModel.currentPhase,
                    completedCount: viewModel.completedPomodoroCount,
                    dailyGoal: viewModel.settings.dailyGoal
                )

                Spacer()

                // 円形タイマー
                CircularTimerView(
                    progress: viewModel.progress,
                    remainingText: viewModel.remainingTimeText,
                    phase: viewModel.currentPhase,
                    themeColor: viewModel.themeColor
                )

                Spacer()

                // コントロールボタン
                TimerControls(viewModel: viewModel)

                // 日次進捗バー
                DailyProgressBar(
                    completedCount: viewModel.completedPomodoroCount,
                    dailyGoal: viewModel.settings.dailyGoal,
                    themeColor: viewModel.themeColor
                )
            }
            .padding()
            .navigationTitle("FocusForge")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Phase Indicator

private struct PhaseIndicator: View {
    let currentPhase: PomodoroPhase
    let completedCount: Int
    let dailyGoal: Int

    var body: some View {
        HStack(spacing: 16) {
            Label(currentPhase.label, systemImage: currentPhase.systemImageName)
                .font(.title2.bold())
                .foregroundStyle(currentPhase == .work ? .orange : .green)

            Spacer()

            Text("\(completedCount) / \(dailyGoal)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
    }
}

// MARK: - Circular Timer

private struct CircularTimerView: View {
    let progress: Double
    let remainingText: String
    let phase: PomodoroPhase
    let themeColor: Color

    var body: some View {
        ZStack {
            // 背景リング
            Circle()
                .stroke(themeColor.opacity(0.15), lineWidth: 20)

            // 進捗リング
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    themeColor,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            // 中央テキスト
            VStack(spacing: 8) {
                Image(systemName: phase.systemImageName)
                    .font(.system(size: 40))
                    .foregroundStyle(themeColor)

                Text(remainingText)
                    .font(.system(size: 60, weight: .thin, design: .monospaced))
                    .contentTransition(.numericText())

                Text(phase.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 280, height: 280)
    }
}

// MARK: - Timer Controls

private struct TimerControls: View {
    @Bindable var viewModel: PomodoroViewModel

    var body: some View {
        HStack(spacing: 24) {
            if viewModel.isRunning {
                // リセットボタン
                Button {
                    Task { await viewModel.endSession() }
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.red)
                }

                // 一時停止 / 再開ボタン
                Button {
                    Task {
                        if viewModel.isPaused {
                            await viewModel.resume()
                        } else {
                            await viewModel.pause()
                        }
                    }
                } label: {
                    Image(systemName: viewModel.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(viewModel.themeColor)
                }

                // スキップボタン
                Button {
                    Task {
                        if viewModel.currentPhase == .work {
                            await viewModel.transitionToBreak()
                        } else {
                            await viewModel.transitionToWork()
                        }
                    }
                } label: {
                    Image(systemName: "forward.end.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.secondary)
                }
            } else {
                // 開始ボタン
                Button {
                    Task { await viewModel.start() }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(viewModel.themeColor)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isRunning)
    }
}

// MARK: - Daily Progress Bar

private struct DailyProgressBar: View {
    let completedCount: Int
    let dailyGoal: Int
    let themeColor: Color

    private var progressValue: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(completedCount) / Double(dailyGoal), 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("今日の目標")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(completedCount) / \(dailyGoal) ポモドーロ")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(themeColor.opacity(0.15))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(themeColor)
                        .frame(width: geometry.size.width * progressValue)
                        .animation(.easeInOut, value: progressValue)
                }
            }
            .frame(height: 12)
        }
    }
}
