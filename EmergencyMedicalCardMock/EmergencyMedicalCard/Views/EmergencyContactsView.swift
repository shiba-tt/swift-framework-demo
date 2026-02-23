import SwiftUI

struct EmergencyContactsView: View {
    @Bindable var viewModel: EmergencyMedicalCardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let profile = viewModel.selectedProfile {
                        // Primary Contact
                        if let primary = profile.primaryContact {
                            primaryContactCard(primary)
                        }

                        // All Contacts
                        contactListSection(contacts: profile.emergencyContacts)

                        // Doctor Info (if accessible)
                        if viewModel.canViewInsurance {
                            doctorCard(profile: profile)
                        }

                        // Quick Actions
                        quickActionsSection(profile: profile)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("緊急連絡先")
        }
    }

    // MARK: - Primary Contact

    private func primaryContactCard(_ contact: EmergencyContact) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            Text(contact.name)
                .font(.title3)
                .fontWeight(.bold)

            Text(contact.relationship)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                // Mock: 電話発信
            } label: {
                HStack {
                    Image(systemName: "phone.fill")
                    Text(contact.phoneNumber)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text("第一緊急連絡先")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.red)
                .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Contact List

    private func contactListSection(contacts: [EmergencyContact]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.blue)
                Text("連絡先一覧")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            ForEach(contacts) { contact in
                HStack(spacing: 12) {
                    Image(systemName: contact.isPrimary ? "star.circle.fill" : "person.circle")
                        .font(.title2)
                        .foregroundStyle(contact.isPrimary ? .yellow : .gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(contact.relationship)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        // Mock: 電話発信
                    } label: {
                        Image(systemName: "phone.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Doctor Card

    private func doctorCard(profile: MedicalProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "cross.case.fill")
                    .foregroundStyle(.red)
                Text("かかりつけ医")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            HStack(spacing: 12) {
                Image(systemName: "stethoscope.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.primaryDoctorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(profile.primaryDoctorPhone)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    // Mock: 電話発信
                } label: {
                    Image(systemName: "phone.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Quick Actions

    private func quickActionsSection(profile: MedicalProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.orange)
                Text("クイックアクション")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            HStack(spacing: 12) {
                quickActionButton(
                    title: "119番",
                    icon: "phone.badge.waveform.fill",
                    color: .red
                )
                quickActionButton(
                    title: "位置情報共有",
                    icon: "location.fill",
                    color: .blue
                )
                quickActionButton(
                    title: "情報コピー",
                    icon: "doc.on.doc.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func quickActionButton(title: String, icon: String, color: Color) -> some View {
        Button {
            // Mock action
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(color)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    EmergencyContactsView(viewModel: EmergencyMedicalCardViewModel())
}
