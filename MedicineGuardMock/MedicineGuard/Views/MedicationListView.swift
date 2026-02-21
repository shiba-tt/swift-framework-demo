import SwiftUI

/// 登録済み薬一覧画面
struct MedicationListView: View {
    @Bindable var viewModel: MedicationViewModel
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.medications.isEmpty {
                    emptyState
                } else {
                    medicationList
                }
            }
            .navigationTitle("お薬一覧")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddMedicationView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("お薬が登録されていません", systemImage: "pills")
        } description: {
            Text("右上の + ボタンからお薬を登録してください")
        } actions: {
            Button("お薬を追加") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Medication List

    private var medicationList: some View {
        List {
            // AlarmKit 情報
            alarmKitSection

            // 薬一覧
            ForEach(viewModel.medications, id: \.id) { medication in
                MedicationRow(medication: medication, viewModel: viewModel)
            }
        }
    }

    // MARK: - AlarmKit Section

    private var alarmKitSection: some View {
        Section {
            LabeledContent("フレームワーク") {
                Text("AlarmKit")
            }
            LabeledContent("スケジュール方式") {
                Text("相対スケジュール（繰り返し）")
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
            Text("服薬アラームはサイレントモード・集中モードを貫通して通知されます。飲み忘れを確実に防ぎます。")
        }
    }
}

// MARK: - Medication Row

private struct MedicationRow: View {
    let medication: Medication
    let viewModel: MedicationViewModel

    var body: some View {
        HStack {
            // カテゴリアイコン
            Image(systemName: medication.category.systemImageName)
                .font(.title3)
                .foregroundStyle(medication.isActive ? .blue : .gray)
                .frame(width: 36)

            // 薬の情報
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.subheadline.bold())

                Text("\(medication.dosage) — \(medication.scheduleDescription)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 有効/無効トグル
            Toggle("", isOn: Binding(
                get: { medication.isActive },
                set: { _ in
                    Task { await viewModel.toggleMedication(medication) }
                }
            ))
            .labelsHidden()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await viewModel.deleteMedication(medication) }
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }
}
