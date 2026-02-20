import SwiftUI

// MARK: - カスタムタイマー追加ビュー

/// 手動でカスタムタイマーを作成するビュー
struct AddTimerView: View {
    let viewModel: TimerViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var timerName = ""
    @State private var selectedCategory: CookingCategory = .boil
    @State private var minutes = 5
    @State private var seconds = 0

    var body: some View {
        NavigationStack {
            Form {
                // タイマー名
                Section("タイマー名") {
                    TextField("例: パスタ茹で", text: $timerName)
                }

                // カテゴリ選択
                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(CookingCategory.allCases, id: \.self) { category in
                            Label {
                                Text(category.displayName)
                            } icon: {
                                Text(category.emoji)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // 時間設定
                Section("タイマー時間") {
                    HStack {
                        Picker("分", selection: $minutes) {
                            ForEach(0...180, id: \.self) { m in
                                Text("\(m)分").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Picker("秒", selection: $seconds) {
                            ForEach(0..<60, id: \.self) { s in
                                Text("\(s)秒").tag(s)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 150)

                    // 合計時間表示
                    HStack {
                        Text("合計")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formattedTotalTime)
                            .font(.headline)
                            .monospacedDigit()
                    }
                }

                // プレビュー
                Section("プレビュー") {
                    HStack(spacing: 12) {
                        Text(selectedCategory.emoji)
                            .font(.largeTitle)

                        VStack(alignment: .leading) {
                            Text(timerName.isEmpty ? "\(selectedCategory.displayName)タイマー" : timerName)
                                .font(.headline)
                            Text(selectedCategory.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(formattedTotalTime)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("カスタムタイマー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("開始") {
                        Task {
                            await viewModel.startCustomTimer(
                                name: timerName,
                                category: selectedCategory,
                                minutes: minutes,
                                seconds: seconds
                            )
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(totalSeconds == 0)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var totalSeconds: Int {
        minutes * 60 + seconds
    }

    private var formattedTotalTime: String {
        if minutes > 0 && seconds > 0 {
            return "\(minutes)分\(seconds)秒"
        } else if minutes > 0 {
            return "\(minutes)分"
        } else {
            return "\(seconds)秒"
        }
    }
}

#Preview {
    AddTimerView(viewModel: TimerViewModel())
}
