import SwiftUI

struct AnalysisView: View {
    @Bindable var viewModel: AIFormCoachViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let session = viewModel.activeSession {
                    analysisContent(session)
                } else {
                    emptyState
                }
            }
            .navigationTitle("リアルタイム分析")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("ワークアウトを開始してください")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("ワークアウトタブからエクササイズを選択して開始します")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Analysis Content

    private func analysisContent(_ session: WorkoutSession) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                cameraPreview(session)
                sessionStats(session)
                analyzeButton
                if let analysis = session.latestAnalysis {
                    scoreCard(analysis)
                    jointResults(analysis)
                    adviceSection(analysis)
                }
                endButton
            }
            .padding()
        }
    }

    // MARK: - Camera Preview (Mock)

    private func cameraPreview(_ session: WorkoutSession) -> some View {
        ZStack {
            // カメラプレビューのモック
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .overlay {
                    VStack(spacing: 16) {
                        // 骨格プレビューのモック
                        Image(systemName: session.exercise.icon)
                            .font(.system(size: 80))
                            .foregroundStyle(.cyan.opacity(0.6))

                        if viewModel.isAnalyzing {
                            ProgressView()
                                .tint(.cyan)
                            Text("姿勢を分析中...")
                                .font(.caption)
                                .foregroundStyle(.white)
                        } else {
                            Text("カメラプレビュー")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }

            // AR オーバーレイ風の表示
            VStack {
                HStack {
                    skeletonBadge(session)
                    Spacer()
                    repCountBadge(session)
                }
                .padding()

                Spacer()

                if let analysis = session.latestAnalysis {
                    liveScoreBadge(analysis)
                        .padding()
                }
            }
        }
    }

    private func skeletonBadge(_ session: WorkoutSession) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
            Text("\(session.exercise.targetJoints.count) 関節を追跡中")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.black.opacity(0.6))
        .clipShape(Capsule())
    }

    private func repCountBadge(_ session: WorkoutSession) -> some View {
        VStack(spacing: 2) {
            Text("\(session.repCount)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text("回")
                .font(.system(size: 10))
        }
        .foregroundStyle(.white)
        .padding(10)
        .background(.cyan.opacity(0.8))
        .clipShape(Circle())
    }

    private func liveScoreBadge(_ analysis: FormAnalysis) -> some View {
        HStack(spacing: 8) {
            scoreCircle(analysis.overallScore, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(analysis.scoreGrade.rawValue)
                    .font(.caption.bold())
                Text("スコア \(analysis.overallScore)")
                    .font(.system(size: 10).monospacedDigit())
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.7))
        .clipShape(Capsule())
    }

    // MARK: - Session Stats

    private func sessionStats(_ session: WorkoutSession) -> some View {
        HStack {
            statItem(title: "レップ数", value: "\(session.repCount)", icon: "repeat")
            statItem(title: "平均スコア", value: "\(session.averageScore)", icon: "chart.bar.fill")
            statItem(title: "ベスト", value: "\(session.bestScore)", icon: "trophy.fill")
            statItem(title: "経過時間", value: session.durationText, icon: "clock.fill")
        }
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.cyan)
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Analyze Button

    private var analyzeButton: some View {
        Button {
            viewModel.analyzeForm()
        } label: {
            Label(
                viewModel.isAnalyzing ? "分析中..." : "フォームを分析",
                systemImage: viewModel.isAnalyzing ? "waveform" : "camera.viewfinder"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .tint(.cyan)
        .disabled(viewModel.isAnalyzing)
    }

    // MARK: - Score Card

    private func scoreCard(_ analysis: FormAnalysis) -> some View {
        VStack(spacing: 16) {
            scoreCircle(analysis.overallScore, size: 80)

            Text(analysis.scoreGrade.rawValue)
                .font(.title3.bold())

            Text("総合スコア")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func scoreCircle(_ score: Int, size: CGFloat) -> some View {
        let color = scoreColor(score)

        return ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: size * 0.08)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: Double(score) / 100.0)
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            Text("\(score)")
                .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: .green
        case 75..<90: .cyan
        case 60..<75: .yellow
        default: .red
        }
    }

    // MARK: - Joint Results

    private func jointResults(_ analysis: FormAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("関節別分析")
                .font(.headline)

            ForEach(analysis.jointResults) { joint in
                jointRow(joint)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func jointRow(_ joint: JointAnalysis) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "angle")
                    .foregroundStyle(statusColor(joint.status))
                    .frame(width: 20)

                Text(joint.jointName)
                    .font(.subheadline.bold())

                Spacer()

                Text(joint.status.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(statusColor(joint.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor(joint.status).opacity(0.12))
                    .clipShape(Capsule())
            }

            HStack {
                Text("現在: \(joint.currentAngle)°")
                    .font(.caption.monospacedDigit())
                Text("→")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("理想: \(joint.idealAngle)° ± \(joint.tolerance)°")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text("スコア: \(joint.score)")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(scoreColor(joint.score))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.gray.opacity(0.1))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(scoreColor(joint.score))
                        .frame(width: geometry.size.width * Double(joint.score) / 100.0)
                }
            }
            .frame(height: 6)
        }
    }

    private func statusColor(_ status: JointStatus) -> Color {
        switch status {
        case .perfect: .green
        case .acceptable: .cyan
        case .warning: .yellow
        case .critical: .red
        }
    }

    // MARK: - Advice Section

    private func adviceSection(_ analysis: FormAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .foregroundStyle(.cyan)
                Text("AI コーチのアドバイス")
                    .font(.headline)
            }

            ForEach(Array(analysis.advice.enumerated()), id: \.offset) { _, advice in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                        .padding(.top, 2)
                    Text(advice)
                        .font(.subheadline)
                }
            }

            Text("※ Foundation Models によりオンデバイスで自然言語アドバイスを生成。プライバシーを完全に保護しながら、パーソナルトレーナーのようなフィードバックを提供します。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(.cyan.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - End Button

    private var endButton: some View {
        Button(role: .destructive) {
            viewModel.endSession()
        } label: {
            Label("ワークアウトを終了", systemImage: "stop.circle.fill")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }
}

#Preview {
    AnalysisView(viewModel: AIFormCoachViewModel())
}
