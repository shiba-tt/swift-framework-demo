import SwiftUI

/// 薬追加画面
struct AddMedicationView: View {
    @Bindable var viewModel: MedicationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var dosage = ""
    @State private var category: MedicationCategory = .prescription
    @State private var scheduleType: MedicationScheduleType = .daily
    @State private var scheduleTime = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: .now
    ) ?? .now
    @State private var repeatDays: Set<MedicationWeekday> = [.monday]
    @State private var snoozeDuration: TimeInterval = 30 * 60
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報
                basicInfoSection

                // カテゴリ
                categorySection

                // スケジュール
                scheduleSection

                // スヌーズ
                snoozeSection

                // メモ
                notesSection
            }
            .navigationTitle("お薬を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        addMedication()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }

    // MARK: - Basic Info Section

    private var basicInfoSection: some View {
        Section("基本情報") {
            TextField("薬の名前", text: $name)
            TextField("用量（例: 5mg）", text: $dosage)
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        Section("カテゴリ") {
            Picker("カテゴリ", selection: $category) {
                ForEach(MedicationCategory.allCases) { cat in
                    Label(cat.label, systemImage: cat.systemImageName)
                        .tag(cat)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Schedule Section

    private var scheduleSection: some View {
        Section("スケジュール") {
            Picker("頻度", selection: $scheduleType) {
                ForEach(MedicationScheduleType.allCases) { type in
                    Text(type.label).tag(type)
                }
            }

            DatePicker(
                "服用時刻",
                selection: $scheduleTime,
                displayedComponents: .hourAndMinute
            )

            if scheduleType == .weekly {
                weekdayPicker
            }
        }
    }

    private var weekdayPicker: some View {
        HStack(spacing: 6) {
            ForEach(MedicationWeekday.allCases) { day in
                Button {
                    toggleDay(day)
                } label: {
                    Text(day.shortLabel)
                        .font(.caption2.bold())
                        .frame(width: 32, height: 32)
                        .background(
                            repeatDays.contains(day)
                                ? Color.blue
                                : Color.gray.opacity(0.2),
                            in: Circle()
                        )
                        .foregroundStyle(
                            repeatDays.contains(day) ? .white : .primary
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Snooze Section

    private var snoozeSection: some View {
        Section("スヌーズ") {
            Stepper(
                value: Binding(
                    get: { Int(snoozeDuration / 60) },
                    set: { snoozeDuration = TimeInterval($0 * 60) }
                ),
                in: 5...120,
                step: 5
            ) {
                HStack {
                    Label("スヌーズ時間", systemImage: "clock.badge.fill")
                    Spacer()
                    Text("\(Int(snoozeDuration / 60))分")
                        .foregroundStyle(.secondary)
                }
            }
        } footer: {
            Text("アラームの「○分後」ボタンをタップすると、指定時間後に再通知されます。")
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        Section("メモ") {
            TextField("服薬に関するメモ", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    // MARK: - Actions

    private func toggleDay(_ day: MedicationWeekday) {
        if repeatDays.contains(day) {
            repeatDays.remove(day)
        } else {
            repeatDays.insert(day)
        }
    }

    private func addMedication() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: scheduleTime)
        let minute = calendar.component(.minute, from: scheduleTime)

        let medication = Medication(
            name: name,
            dosage: dosage,
            category: category,
            scheduleType: scheduleType,
            scheduleHour: hour,
            scheduleMinute: minute,
            repeatDays: scheduleType == .weekly ? repeatDays.map(\.rawValue) : [],
            notes: notes,
            snoozeDuration: snoozeDuration
        )

        Task {
            await viewModel.addMedication(medication)
            dismiss()
        }
    }
}
