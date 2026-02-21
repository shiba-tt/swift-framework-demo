import SwiftUI

/// アラーム設定・睡眠モニタリング画面
struct AlarmView: View {
    @Bindable var viewModel: SleepViewModel
    @State private var showingPhaseDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 時刻表示
                    timeDisplay

                    // 睡眠ステータス
                    if viewModel.isSleeping {
                        sleepingStatusCard
                    } else {
                        nextAlarmCard
                    }

                    // アクションボタン
                    actionButton

                    // 睡眠ステージ表示（モニタリング中）
                    if viewModel.isSleeping {
                        sleepPhaseCard
                    }
                }
                .padding()
            }
            .navigationTitle("SleepCraft")
            .task {
                await viewModel.requestAllAuthorizations()
            }
        }
    }

    // MARK: - Components

    private var timeDisplay: some View {
        VStack(spacing: 8) {
            Text(Date.now, style: .time)
                .font(.system(size: 56, weight: .thin, design: .rounded))
                .monospacedDigit()

            Text(Date.now, format: .dateTime.month().day().weekday(.wide))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    private var nextAlarmCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "alarm.fill")
                .font(.largeTitle)
                .foregroundStyle(.indigo)

            if viewModel.settings.isEnabled {
                Text("次のアラーム")
                    .font(.headline)

                Text(viewModel.settings.wakeUpTimeToday, style: .time)
                    .font(.system(size: 28, weight: .medium, design: .rounded))

                if viewModel.settings.isSmartAlarmEnabled {
                    Label(
                        "スマートウィンドウ: \(viewModel.settings.smartWindowMinutes)分前から",
                        systemImage: "brain.head.profile.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Text(viewModel.settings.repeatDaysText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("アラーム未設定")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }

    private var sleepingStatusCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz.fill")
                .font(.largeTitle)
                .foregroundStyle(.indigo)

            Text("睡眠モニタリング中")
                .font(.headline)

            HStack(spacing: 24) {
                VStack {
                    Text("睡眠スコア")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.sleepScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.indigo)
                }

                VStack {
                    Text("現在のステージ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label(viewModel.currentPhase.label, systemImage: viewModel.currentPhase.systemImageName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            Text("アラーム: \(viewModel.settings.wakeUpTimeToday, style: .time)")
                .font(.caption)
                .foregroundStyle(.secondary)

            if viewModel.settings.isSmartAlarmEnabled {
                Text("浅い睡眠を検知すると最適なタイミングで起こします")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }

    private var actionButton: some View {
        Group {
            if viewModel.isSleeping {
                Button {
                    Task { await viewModel.cancelAlarm() }
                } label: {
                    Label("アラームを解除", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else {
                Button {
                    Task { await viewModel.setAlarm() }
                } label: {
                    Label("おやすみ", systemImage: "moon.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .disabled(!viewModel.settings.isEnabled)
            }
        }
    }

    private var sleepPhaseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("睡眠ステージ履歴")
                .font(.headline)

            if viewModel.phaseHistory.isEmpty {
                Text("データ収集中...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                // 睡眠ステージのバー表示
                HStack(spacing: 2) {
                    ForEach(Array(viewModel.phaseHistory.suffix(30).enumerated()), id: \.offset) { _, entry in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(phaseColor(entry.phase))
                            .frame(height: CGFloat(10 + entry.phase.depthScore * 10))
                    }
                }
                .frame(height: 40, alignment: .bottom)

                // 凡例
                HStack(spacing: 16) {
                    ForEach(SleepPhase.allCases) { phase in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(phaseColor(phase))
                                .frame(width: 8, height: 8)
                            Text(phase.label)
                                .font(.caption2)
                        }
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }

    private func phaseColor(_ phase: SleepPhase) -> Color {
        switch phase {
        case .awake: .yellow
        case .rem: .cyan
        case .core: .blue
        case .deep: .indigo
        }
    }
}
