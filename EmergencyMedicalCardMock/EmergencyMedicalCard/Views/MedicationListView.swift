import SwiftUI

struct MedicationListView: View {
    @Bindable var viewModel: EmergencyMedicalCardViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.canViewConditions {
                    medicationContent
                } else {
                    lockedView
                }
            }
            .navigationTitle("服薬情報")
            .sheet(isPresented: $viewModel.showPINSheet) {
                PINEntryView(viewModel: viewModel)
                    .presentationDetents([.medium])
            }
        }
    }

    private var medicationContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let profile = viewModel.selectedProfile {
                    // Essential Medications
                    if !profile.essentialMedications.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text("必須薬")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }

                            ForEach(profile.essentialMedications) { medication in
                                medicationRow(medication, isEssential: true)
                            }
                        }
                        .padding()
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // All Medications
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "pill.fill")
                                .foregroundStyle(.blue)
                            Text("服薬リスト")
                                .font(.headline)
                                .fontWeight(.bold)
                        }

                        ForEach(profile.medications) { medication in
                            medicationRow(medication, isEssential: false)
                        }
                    }
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Summary
                    summaryCard(profile: profile)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func medicationRow(_ medication: Medication, isEssential: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: medication.isEssential ? "pill.circle.fill" : "pill.fill")
                .font(.title2)
                .foregroundStyle(medication.isEssential ? .red : .blue)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(medication.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if medication.isEssential && !isEssential {
                        Text("必須")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.red)
                            .clipShape(Capsule())
                    }
                }

                Text("\(medication.dosage) / \(medication.frequency.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(medication.purpose)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func summaryCard(profile: MedicalProfile) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.purple)
                Text("サマリー")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            HStack(spacing: 16) {
                summaryTile(
                    title: "総薬数",
                    value: "\(profile.medications.count)",
                    color: .blue
                )
                summaryTile(
                    title: "必須薬",
                    value: "\(profile.essentialMedications.count)",
                    color: .red
                )
                summaryTile(
                    title: "アレルギー",
                    value: "\(profile.allergies.count)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func summaryTile(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("認証が必要です")
                .font(.title2)
                .fontWeight(.bold)

            Text("服薬情報を閲覧するにはPINコードによる認証が必要です")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.requestAuthentication()
            } label: {
                HStack {
                    Image(systemName: "lock.open.fill")
                    Text("認証して解除")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

#Preview {
    MedicationListView(viewModel: EmergencyMedicalCardViewModel())
}
