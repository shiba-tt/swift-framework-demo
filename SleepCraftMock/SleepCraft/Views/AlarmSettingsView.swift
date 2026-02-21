import SwiftUI

/// アラーム設定画面
struct AlarmSettingsView: View {
    @Bindable var viewModel: SleepViewModel

    private let dayNames = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        NavigationStack {
            Form {
                // アラーム ON/OFF
                Section {
                    Toggle("アラーム", isOn: $viewModel.settings.isEnabled)
                }

                // 起床時刻
                Section("起床時刻") {
                    DatePicker(
                        "起床希望時刻",
                        selection: viewModel.wakeUpTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                }

                // スマートアラーム
                Section("スマートアラーム") {
                    Toggle(isOn: $viewModel.settings.isSmartAlarmEnabled) {
                        VStack(alignment: .leading) {
                            Text("スマートアラーム")
                            Text("浅い睡眠のタイミングで起こします")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if viewModel.settings.isSmartAlarmEnabled {
                        Stepper(
                            "ウィンドウ: \(viewModel.settings.smartWindowMinutes)分前",
                            value: $viewModel.settings.smartWindowMinutes,
                            in: 10...60,
                            step: 5
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("アラーム範囲")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(viewModel.settings.smartWindowStart, style: .time) 〜 \(viewModel.settings.wakeUpTimeToday, style: .time)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }

                // スヌーズ
                Section("スヌーズ") {
                    Stepper(
                        "\(viewModel.settings.snoozeDurationMinutes)分",
                        value: $viewModel.settings.snoozeDurationMinutes,
                        in: 1...30
                    )
                }

                // 繰り返し
                Section("繰り返し") {
                    ForEach(0..<7, id: \.self) { day in
                        Toggle(dayNames[day], isOn: Binding(
                            get: { viewModel.settings.repeatDays.contains(day) },
                            set: { isOn in
                                if isOn {
                                    viewModel.settings.repeatDays.insert(day)
                                } else {
                                    viewModel.settings.repeatDays.remove(day)
                                }
                            }
                        ))
                    }
                }

                // 説明
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("仕組み", systemImage: "info.circle")
                            .font(.headline)

                        Text("1. 就寝時に「おやすみ」をタップ")
                        Text("2. Apple Watch の睡眠データをリアルタイム監視")
                        Text("3. スマートウィンドウ内で浅い睡眠を検知")
                        Text("4. 最適なタイミングでアラームが発火")
                        Text("5. ウィンドウ終了時刻にフォールバックアラーム")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("設定")
        }
    }
}
