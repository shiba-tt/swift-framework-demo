import SwiftUI

struct CookingView: View {
    @Bindable var viewModel: VoiceRecipeViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let session = viewModel.activeSession {
                    cookingContent(session)
                } else {
                    emptyState
                }
            }
            .navigationTitle("調理中")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "frying.pan")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("調理中のレシピはありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("レシピタブからレシピを選んで調理を開始してください")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Cooking Content

    private func cookingContent(_ session: CookingSession) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection(session)
                progressSection(session)
                currentStepCard(session)
                timerSection(session)
                navigationButtons(session)
                nextStepPreview(session)
                voiceCommandSection(session)
                servingsSection(session)
                endButton
            }
            .padding()
        }
    }

    // MARK: - Header

    private func headerSection(_ session: CookingSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.recipe.name)
                    .font(.title2.bold())
                HStack(spacing: 8) {
                    Label("\(session.adjustedServings)人分", systemImage: "person.2.fill")
                    if session.adjustedServings != session.recipe.servings {
                        Text("(元: \(session.recipe.servings)人分)")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            liveActivityBadge(session)
        }
    }

    private func liveActivityBadge(_ session: CookingSession) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "livephoto")
                .font(.caption)
            Text("Live")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.orange.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Progress

    private func progressSection(_ session: CookingSession) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("ステップ \(session.currentStepIndex + 1) / \(session.recipe.steps.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(session.progressRatio * 100))%")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(.orange)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.15))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.orange.gradient)
                        .frame(width: geometry.size.width * session.progressRatio)
                        .animation(.spring(duration: 0.3), value: session.progressRatio)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Current Step

    private func currentStepCard(_ session: CookingSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "\(session.currentStepIndex + 1).circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("現在のステップ")
                    .font(.subheadline.bold())
                Spacer()
                if session.currentStep?.hasTimer == true {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                }
            }

            if let step = session.currentStep {
                Text(step.instruction)
                    .font(.body)
                    .lineSpacing(4)

                if let timerText = step.timerText {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.orange)
                        Text("目安時間: \(timerText)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Timer

    private func timerSection(_ session: CookingSession) -> some View {
        Group {
            if session.isTimerRunning || session.timerRemainingSeconds != nil {
                VStack(spacing: 12) {
                    Text(session.timerRemainingText ?? "0:00")
                        .font(.system(size: 48, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(
                            session.isTimerRunning
                                ? (session.timerRemainingSeconds ?? 0 <= 10 ? .red : .orange)
                                : .secondary
                        )

                    if session.isTimerRunning {
                        Text("タイマー作動中")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if session.timerRemainingSeconds == 0 {
                        Text("タイマー完了！")
                            .font(.subheadline.bold())
                            .foregroundStyle(.green)
                    }

                    HStack(spacing: 16) {
                        if session.isTimerRunning {
                            Button {
                                viewModel.stopTimer()
                            } label: {
                                Label("停止", systemImage: "stop.fill")
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        } else if session.currentStep?.hasTimer == true {
                            Button {
                                viewModel.startStepTimer()
                            } label: {
                                Label("タイマー開始", systemImage: "play.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else if session.currentStep?.hasTimer == true {
                Button {
                    viewModel.startStepTimer()
                } label: {
                    Label("タイマーを開始", systemImage: "timer")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
    }

    // MARK: - Navigation Buttons

    private func navigationButtons(_ session: CookingSession) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.previousStep()
            } label: {
                Label("前へ", systemImage: "backward.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(session.isFirstStep)

            Button {
                viewModel.repeatCurrentStep()
            } label: {
                Label("もう一回", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                viewModel.nextStep()
            } label: {
                Label("次へ", systemImage: "forward.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(session.isLastStep)
        }
    }

    // MARK: - Next Step Preview

    private func nextStepPreview(_ session: CookingSession) -> some View {
        Group {
            if let nextStep = session.nextStep {
                VStack(alignment: .leading, spacing: 8) {
                    Text("次のステップ")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: "\(nextStep.order).circle")
                            .foregroundStyle(.secondary)
                        Text(nextStep.instruction)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Voice Command Section

    private func voiceCommandSection(_ session: CookingSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .foregroundStyle(.orange)
                Text("音声コマンド")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 6) {
                siriCommandRow("「次のステップ」", action: "次の工程へ進む")
                siriCommandRow("「前のステップに戻って」", action: "前の工程に戻る")
                siriCommandRow("「もう一回」", action: "現在のステップを繰り返す")
                siriCommandRow("「タイマー開始」", action: "ステップのタイマーを開始")
                siriCommandRow("「○人分に変更して」", action: "分量を自動再計算")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func siriCommandRow(_ command: String, action: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "mic.fill")
                .font(.caption2)
                .foregroundStyle(.orange)
                .frame(width: 16)

            Text(command)
                .font(.caption.bold())
                .foregroundStyle(.primary)

            Text("→")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(action)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Servings Adjustment

    private func servingsSection(_ session: CookingSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("人数変更")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach([1, 2, 3, 4], id: \.self) { count in
                    Button {
                        viewModel.adjustServings(count)
                    } label: {
                        Text("\(count)人分")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(session.adjustedServings == count ? .orange : .secondary)
                }
            }

            if session.adjustedServings != session.recipe.servings {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.orange)
                    Text("分量が \(String(format: "%.1f", session.servingsMultiplier)) 倍に調整されています")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - End Button

    private var endButton: some View {
        Button(role: .destructive) {
            viewModel.endSession()
        } label: {
            Label("調理を終了", systemImage: "stop.circle.fill")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }
}

#Preview {
    CookingView(viewModel: VoiceRecipeViewModel())
}
