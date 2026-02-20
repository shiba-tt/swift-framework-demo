import SwiftUI

/// 設定画面
struct SettingsView: View {
    @Bindable var settings: PomodoroSettings
    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // タイマー設定
                timerSection

                // 動作設定
                behaviorSection

                // 目標設定
                goalSection

                // AlarmKit 情報
                alarmKitSection

                // リセット
                resetSection
            }
            .navigationTitle("設定")
            .alert("設定をリセット", isPresented: $showingResetAlert) {
                Button("リセット", role: .destructive) {
                    resetToDefaults()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("すべての設定をデフォルト値に戻しますか？")
            }
        }
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        Section("タイマー") {
            DurationPicker(
                title: "作業時間",
                systemImage: "brain.head.profile",
                color: .orange,
                duration: $settings.workDuration
            )
            DurationPicker(
                title: "短い休憩",
                systemImage: "cup.and.saucer.fill",
                color: .green,
                duration: $settings.shortBreakDuration
            )
            DurationPicker(
                title: "長い休憩",
                systemImage: "figure.walk",
                color: .blue,
                duration: $settings.longBreakDuration
            )

            Stepper(value: $settings.longBreakInterval, in: 2...8) {
                HStack {
                    Label("長い休憩の間隔", systemImage: "repeat")
                    Spacer()
                    Text("\(settings.longBreakInterval) ポモドーロごと")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Behavior Section

    private var behaviorSection: some View {
        Section("動作") {
            Toggle(isOn: $settings.autoStartNextPhase) {
                Label("自動で次のフェーズを開始", systemImage: "arrow.right.circle")
            }
        } footer: {
            Text("有効にすると、フェーズ完了時にアラームの Stop ボタンをタップするだけで次のフェーズが自動的に開始されます。")
        }
    }

    // MARK: - Goal Section

    private var goalSection: some View {
        Section("目標") {
            Stepper(value: $settings.dailyGoal, in: 1...20) {
                HStack {
                    Label("1日の目標", systemImage: "target")
                    Spacer()
                    Text("\(settings.dailyGoal) ポモドーロ")
                        .foregroundStyle(.secondary)
                }
            }
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
            LabeledContent("集中モード貫通") {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        } header: {
            Text("AlarmKit")
        } footer: {
            Text("AlarmKit はシステムデーモンによりアラームを管理するため、サイレントモードや集中モードを貫通して通知されます。")
        }
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        Section {
            Button("設定をリセット", role: .destructive) {
                showingResetAlert = true
            }
        }
    }

    private func resetToDefaults() {
        settings.workDuration = 25 * 60
        settings.shortBreakDuration = 5 * 60
        settings.longBreakDuration = 15 * 60
        settings.longBreakInterval = 4
        settings.autoStartNextPhase = false
        settings.dailyGoal = 8
    }
}

// MARK: - Duration Picker

private struct DurationPicker: View {
    let title: String
    let systemImage: String
    let color: Color
    @Binding var duration: TimeInterval

    private var minutes: Int {
        Int(duration) / 60
    }

    var body: some View {
        Stepper(value: Binding(
            get: { minutes },
            set: { duration = TimeInterval($0 * 60) }
        ), in: 1...120) {
            HStack {
                Label(title, systemImage: systemImage)
                    .foregroundStyle(color)
                Spacer()
                Text("\(minutes) 分")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
