import SwiftUI

/// ルーティン設定画面
struct RoutineEditorView: View {
    @Bindable var template: RoutineTemplate

    var body: some View {
        NavigationStack {
            Form {
                // 起床時刻
                wakeUpSection

                // ステップ別の時間設定
                stepDurationsSection

                // スヌーズ設定
                snoozeSection

                // 繰り返し曜日
                repeatDaysSection

                // AlarmKit 情報
                alarmKitSection
            }
            .navigationTitle("設定")
        }
    }

    // MARK: - Wake Up Section

    private var wakeUpSection: some View {
        Section("起床時刻") {
            DatePicker(
                "起床アラーム",
                selection: $template.wakeUpTime,
                displayedComponents: .hourAndMinute
            )

            Toggle(isOn: $template.isEnabled) {
                Label("ルーティンを有効にする", systemImage: "alarm.fill")
            }
        } footer: {
            Text("出発予定時刻: \(template.estimatedDepartureTime, style: .time)（所要時間 \(template.totalDurationMinutes)分）")
        }
    }

    // MARK: - Step Durations Section

    private var stepDurationsSection: some View {
        Section("各ステップの所要時間") {
            ForEach(RoutineStep.allCases.filter(\.isCountdown)) { step in
                StepDurationRow(step: step, durations: $template.stepDurations)
            }
        } footer: {
            Text("起床アラームと出発アラームはカウントダウンなしの即時アラームです。")
        }
    }

    // MARK: - Snooze Section

    private var snoozeSection: some View {
        Section("スヌーズ") {
            Stepper(
                value: Binding(
                    get: { Int(template.snoozeDuration / 60) },
                    set: { template.snoozeDuration = TimeInterval($0 * 60) }
                ),
                in: 1...30
            ) {
                HStack {
                    Label("スヌーズ時間", systemImage: "zzz")
                    Spacer()
                    Text("\(Int(template.snoozeDuration / 60))分")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Repeat Days Section

    private var repeatDaysSection: some View {
        Section("繰り返し") {
            HStack(spacing: 8) {
                ForEach(Weekday.allCases) { day in
                    Button {
                        toggleDay(day)
                    } label: {
                        Text(day.shortLabel)
                            .font(.caption.bold())
                            .frame(width: 36, height: 36)
                            .background(
                                template.repeatDays.contains(day)
                                    ? Color.orange
                                    : Color.gray.opacity(0.2),
                                in: Circle()
                            )
                            .foregroundStyle(
                                template.repeatDays.contains(day) ? .white : .primary
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - AlarmKit Section

    private var alarmKitSection: some View {
        Section {
            LabeledContent("フレームワーク") {
                Text("AlarmKit")
            }
            LabeledContent("最小 iOS バージョン") {
                Text("iOS 26.0")
            }
            LabeledContent("サイレントモード貫通") {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            LabeledContent("チェーンスケジュール") {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        } header: {
            Text("AlarmKit")
        } footer: {
            Text("Stop ボタンの AppIntent で次のアラームを自動スケジュールし、朝のルーティン全体を連鎖的にガイドします。")
        }
    }

    private func toggleDay(_ day: Weekday) {
        if template.repeatDays.contains(day) {
            template.repeatDays.remove(day)
        } else {
            template.repeatDays.insert(day)
        }
    }
}

// MARK: - Step Duration Row

private struct StepDurationRow: View {
    let step: RoutineStep
    @Binding var durations: [RoutineStep: TimeInterval]

    private var minutes: Int {
        Int((durations[step] ?? step.defaultDuration) / 60)
    }

    var body: some View {
        Stepper(
            value: Binding(
                get: { minutes },
                set: { durations[step] = TimeInterval($0 * 60) }
            ),
            in: 1...120
        ) {
            HStack {
                Label(step.label, systemImage: step.systemImageName)
                Spacer()
                Text("\(minutes)分")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
