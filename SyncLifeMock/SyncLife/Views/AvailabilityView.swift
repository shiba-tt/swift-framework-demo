import SwiftUI

struct AvailabilityView: View {
    @Bindable var viewModel: SyncLifeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayScheduleCard
                    commonFreeSlotsCard
                }
                .padding()
            }
            .navigationTitle("\u{7A7A}\u{304D}\u{6642}\u{9593}")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Today's Schedule

    private var todayScheduleCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\u{4ECA}\u{65E5}\u{306E}\u{30B9}\u{30B1}\u{30B8}\u{30E5}\u{30FC}\u{30EB}")
                    .font(.headline)
                Spacer()
                Text(todayDateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.memberSchedules) { schedule in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(schedule.member.color.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(schedule.member.initials)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                                    .foregroundStyle(schedule.member.color)
                            )
                        Text(schedule.member.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    // Timeline bar
                    HStack(spacing: 1) {
                        ForEach(schedule.slots) { slot in
                            let width = CGFloat(slot.endHour - slot.startHour)
                            VStack(spacing: 1) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(slot.availability.color.opacity(0.6))
                                    .frame(height: 20)
                                    .overlay(
                                        Group {
                                            if let title = slot.eventTitle {
                                                Text(title)
                                                    .font(.system(size: 8))
                                                    .lineLimit(1)
                                            }
                                        }
                                    )

                                if schedule.id == viewModel.memberSchedules.first?.id {
                                    Text("\(slot.startHour)")
                                        .font(.system(size: 7))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minWidth: width * 12)
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                SlotLegend(color: .green, label: "\u{7A7A}\u{304D}")
                SlotLegend(color: .red, label: "\u{4E88}\u{5B9A}\u{3042}\u{308A}")
                SlotLegend(color: .yellow, label: "\u{4EEE}")
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Common Free Slots

    private var commonFreeSlotsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\u{5168}\u{54E1}\u{306E}\u{7A7A}\u{304D}\u{6642}\u{9593}")
                    .font(.headline)
                Spacer()
                Text("\u{4ECA}\u{5F8C}7\u{65E5}\u{9593}")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.commonFreeSlots.isEmpty {
                Text("\u{5171}\u{901A}\u{306E}\u{7A7A}\u{304D}\u{6642}\u{9593}\u{304C}\u{898B}\u{3064}\u{304B}\u{308A}\u{307E}\u{305B}\u{3093}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.commonFreeSlots) { slot in
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text(slot.dateText)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(slot.timeText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 80)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(slot.durationText)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)

                            // Available members
                            HStack(spacing: -6) {
                                ForEach(slot.availableMembers) { member in
                                    Circle()
                                        .fill(member.color.opacity(0.3))
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Text(member.initials)
                                                .font(.system(size: 8))
                                                .fontWeight(.bold)
                                                .foregroundStyle(member.color)
                                        )
                                }
                            }
                        }

                        Spacer()

                        Button {
                            // Add event action
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Helpers

    private var todayDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M\u{6708}d\u{65E5} (E)"
        return formatter.string(from: Date())
    }
}

// MARK: - Components

private struct SlotLegend: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color.opacity(0.6))
                .frame(width: 12, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AvailabilityView(viewModel: SyncLifeViewModel())
}
