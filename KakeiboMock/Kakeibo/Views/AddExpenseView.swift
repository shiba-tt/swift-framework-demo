import SwiftUI

struct AddExpenseView: View {
    @Bindable var viewModel: KakeiboViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("金額") {
                    HStack {
                        Text("¥")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        TextField("0", text: $viewModel.addAmount)
                            .font(.title2.bold())
                            .keyboardType(.numberPad)
                    }
                }

                Section("カテゴリ") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 4),
                        spacing: 12
                    ) {
                        ForEach(ExpenseCategory.allCases) { category in
                            categoryButton(category)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("メモ") {
                    TextField("何に使った？", text: $viewModel.addMemo)
                }

                Section {
                    quickAmountButtons
                }
            }
            .navigationTitle("支出を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.addExpense()
                    }
                    .disabled(viewModel.addAmount.isEmpty || Int(viewModel.addAmount) == nil)
                    .bold()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Category Button

    private func categoryButton(_ category: ExpenseCategory) -> some View {
        Button {
            viewModel.addCategory = category
        } label: {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(
                        viewModel.addCategory == category
                            ? category.color.opacity(0.2)
                            : Color(.secondarySystemGroupedBackground)
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                viewModel.addCategory == category ? category.color : .clear,
                                lineWidth: 2
                            )
                    )

                Text(category.displayName)
                    .font(.caption2)
            }
            .foregroundStyle(
                viewModel.addCategory == category ? category.color : .primary
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quick Amount

    private var quickAmountButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("よく使う金額")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach([100, 300, 500, 1000, 3000], id: \.self) { amount in
                    Button("¥\(amount)") {
                        viewModel.addAmount = "\(amount)"
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                }
            }
        }
    }
}
