import SwiftUI

struct EmergencyInfoView: View {
    @Bindable var viewModel: EmergencyMedicalCardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    accessLevelBanner
                    basicInfoSection
                    allergySection

                    if viewModel.canViewConditions {
                        conditionsSection
                    }

                    if viewModel.canViewInsurance {
                        insuranceSection
                        doctorSection
                    }

                    if let next = viewModel.nextAccessLevel {
                        unlockButton(for: next)
                    }

                    if viewModel.currentAccessLevel != .basic {
                        resetButton
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("緊急医療情報")
            .sheet(isPresented: $viewModel.showPINSheet) {
                PINEntryView(viewModel: viewModel)
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            if let profile = viewModel.selectedProfile {
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text(profile.ownerName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                HStack(spacing: 20) {
                    Label("\(profile.age)歳", systemImage: "person.fill")
                    Label(profile.bloodType.displayName, systemImage: "drop.fill")
                    if profile.organDonor {
                        Label("臓器提供", systemImage: "heart.fill")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))

                Text("最終更新: \(viewModel.lastUpdatedText)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [.red, .red.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Access Level

    private var accessLevelBanner: some View {
        HStack {
            Image(systemName: viewModel.currentAccessLevel.icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentAccessLevel.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(viewModel.currentAccessLevel.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if viewModel.criticalAlertCount > 0 {
                Label("\(viewModel.criticalAlertCount)", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(viewModel.currentAccessLevel.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Basic Info

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "基本情報", icon: "person.text.rectangle")

            if let profile = viewModel.selectedProfile {
                HStack(spacing: 16) {
                    infoTile(
                        title: "血液型",
                        value: profile.bloodType.displayName,
                        icon: "drop.fill",
                        color: profile.bloodType.color
                    )
                    infoTile(
                        title: "年齢",
                        value: "\(profile.age)歳",
                        icon: "calendar",
                        color: .blue
                    )
                    infoTile(
                        title: "臓器提供",
                        value: profile.organDonor ? "希望" : "なし",
                        icon: "heart.fill",
                        color: profile.organDonor ? .pink : .gray
                    )
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Allergies

    private var allergySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "アレルギー", icon: "exclamationmark.triangle.fill")

            if let profile = viewModel.selectedProfile {
                ForEach(profile.allergies) { allergy in
                    HStack(spacing: 12) {
                        Image(systemName: allergy.severity.icon)
                            .foregroundStyle(allergy.severity.color)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(allergy.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(allergy.reaction)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(allergy.severity.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(allergy.severity.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(allergy.severity.color.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Conditions (Authenticated)

    private var conditionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "持病・既往歴", icon: "stethoscope")

            if let profile = viewModel.selectedProfile {
                ForEach(profile.conditions) { condition in
                    HStack(spacing: 12) {
                        Image(systemName: condition.severity.icon)
                            .foregroundStyle(condition.severity.color)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(condition.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(condition.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(condition.severity.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(condition.severity.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(condition.severity.color.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Insurance (Full Access)

    private var insuranceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "保険証情報", icon: "creditcard.fill")

            if let insurance = viewModel.selectedProfile?.insurance {
                VStack(spacing: 8) {
                    infoRow(label: "保険者名", value: insurance.providerName)
                    infoRow(label: "記号・番号", value: insurance.policyNumber)
                    infoRow(label: "被保険者", value: insurance.holderName)
                    infoRow(label: "有効期限", value: insurance.validUntil.formatted(.dateTime.year().month().day()))
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var doctorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "かかりつけ医", icon: "cross.case.fill")

            if let profile = viewModel.selectedProfile {
                VStack(spacing: 8) {
                    infoRow(label: "医師名", value: profile.primaryDoctorName)
                    infoRow(label: "電話番号", value: profile.primaryDoctorPhone)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Unlock

    private func unlockButton(for level: AccessLevel) -> some View {
        Button {
            viewModel.requestAuthentication()
        } label: {
            HStack {
                Image(systemName: level.icon)
                Text("\(level.displayName)を解除")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(level.color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var resetButton: some View {
        Button {
            viewModel.resetAccess()
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                Text("アクセスをリセット")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray5))
            .foregroundStyle(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.red)
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    EmergencyInfoView(viewModel: EmergencyMedicalCardViewModel())
}
