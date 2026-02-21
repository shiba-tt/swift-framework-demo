import SwiftUI

/// ルーティン進行画面
struct ActiveRoutineView: View {
    @Bindable var viewModel: RoutineViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // ステップ進捗インジケーター
                StepProgressBar(
                    currentStep: viewModel.currentStep,
                    completedSteps: viewModel.todayRecord?.completedStepCount ?? 0
                )
                .padding(.horizontal)

                Spacer()

                if viewModel.isRunning, let step = viewModel.currentStep {
                    // アクティブなステップ表示
                    ActiveStepView(
                        step: step,
                        progress: viewModel.progress,
                        remainingText: viewModel.remainingTimeText,
                        themeColor: viewModel.themeColor
                    )

                    Spacer()

                    // コントロールボタン
                    RoutineControls(viewModel: viewModel)
                } else {
                    // 待機状態
                    IdleView(viewModel: viewModel)

                    Spacer()
                }

                // ルーティンサマリー
                RoutineSummaryBar(template: viewModel.template)
            }
            .padding()
            .navigationTitle("RitualAlarm")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Step Progress Bar

private struct StepProgressBar: View {
    let currentStep: RoutineStep?
    let completedSteps: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(RoutineStep.allCases) { step in
                VStack(spacing: 4) {
                    Image(systemName: step.systemImageName)
                        .font(.caption)
                        .foregroundStyle(color(for: step))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color(for: step))
                        .frame(height: 6)
                }
            }
        }
    }

    private func color(for step: RoutineStep) -> Color {
        if let current = currentStep, step == current {
            return .orange
        }
        if step.index < (currentStep?.index ?? completedSteps) {
            return .green
        }
        return .gray.opacity(0.3)
    }
}

// MARK: - Active Step View

private struct ActiveStepView: View {
    let step: RoutineStep
    let progress: Double
    let remainingText: String
    let themeColor: Color

    var body: some View {
        VStack(spacing: 20) {
            // ステップ絵文字
            Text(step.emoji)
                .font(.system(size: 60))

            // ステップ名
            Text(step.label)
                .font(.title.bold())
                .foregroundStyle(themeColor)

            if step.isCountdown {
                // カウントダウン円形タイマー
                ZStack {
                    Circle()
                        .stroke(themeColor.opacity(0.15), lineWidth: 16)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            themeColor,
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    Text(remainingText)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .contentTransition(.numericText())
                }
                .frame(width: 220, height: 220)
            } else {
                // アラーム待機表示
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(themeColor)
                    .symbolEffect(.bounce, options: .repeating)

                Text(step.alertSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Idle View

private struct IdleView: View {
    let viewModel: RoutineViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sunrise.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange.gradient)

            Text("朝のルーティン")
                .font(.title.bold())

            Text("アラームが連鎖して朝の準備をガイドします")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.startRoutine() }
            } label: {
                Label("ルーティンを開始", systemImage: "play.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange.gradient, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Routine Controls

private struct RoutineControls: View {
    @Bindable var viewModel: RoutineViewModel

    var body: some View {
        HStack(spacing: 24) {
            // 終了ボタン
            Button {
                Task { await viewModel.endRoutine() }
            } label: {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.red)
            }

            if let step = viewModel.currentStep, step.isCountdown {
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
                        .font(.system(size: 64))
                        .foregroundStyle(viewModel.themeColor)
                }
            }

            // 完了 / 次へボタン
            Button {
                Task { await viewModel.completeCurrentStep() }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }
        }
        .animation(.easeInOut, value: viewModel.isPaused)
    }
}

// MARK: - Routine Summary Bar

private struct RoutineSummaryBar: View {
    let template: RoutineTemplate

    var body: some View {
        HStack {
            Label {
                Text(template.wakeUpTime, style: .time)
                    .font(.caption.bold())
            } icon: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
            }
            .font(.caption)

            Spacer()

            Text("所要時間 \(template.totalDurationMinutes)分")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Label {
                Text(template.estimatedDepartureTime, style: .time)
                    .font(.caption.bold())
            } icon: {
                Image(systemName: "door.left.hand.open")
                    .foregroundStyle(.purple)
            }
            .font(.caption)
        }
        .padding(.horizontal)
    }
}
