import SwiftUI

struct FamilyOverviewView: View {
    @Bindable var viewModel: SyncLifeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    familyMembersCard
                    weeklyStatsCard
                    upcomingEventsCard
                    locationNotificationsCard
                    suggestionsCard
                }
                .padding()
            }
            .navigationTitle("SyncLife")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Family Members

    private var familyMembersCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundStyle(.blue)
                Text(viewModel.familyName)
                    .font(.headline)
                Spacer()
                Text("\(viewModel.familyMembers.count)\u{4EBA}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                ForEach(viewModel.familyMembers) { member in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(member.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(member.initials)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(member.color)
                            )
                        Text(member.name)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Weekly Stats

    private var weeklyStatsCard: some View {
        VStack(spacing: 12) {
            Text("\u{4ECA}\u{9031}\u{306E}\u{307E}\u{3068}\u{3081}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let stats = viewModel.weeklyStats {
                HStack(spacing: 12) {
                    WeekStatItem(
                        icon: "calendar",
                        value: "\(stats.totalFamilyEvents)",
                        label: "\u{5BB6}\u{65CF}\u{30A4}\u{30D9}\u{30F3}\u{30C8}",
                        color: .blue
                    )
                    WeekStatItem(
                        icon: "clock.fill",
                        value: String(format: "%.1fh", stats.sharedHours),
                        label: "\u{5171}\u{6709}\u{6642}\u{9593}",
                        color: .green
                    )
                    WeekStatItem(
                        icon: "checkmark.circle.fill",
                        value: "\(stats.completedTasks)/\(stats.completedTasks + stats.pendingTasks)",
                        label: "\u{30BF}\u{30B9}\u{30AF}",
                        color: .orange
                    )
                    WeekStatItem(
                        icon: "clock.badge.checkmark",
                        value: "\(stats.freeSlots)",
                        label: "\u{7A7A}\u{304D}\u{67A0}",
                        color: .purple
                    )
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Upcoming Events

    private var upcomingEventsCard: some View {
        VStack(spacing: 12) {
            Text("\u{4ECA}\u{5F8C}\u{306E}\u{4E88}\u{5B9A}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.upcomingEvents.prefix(3)) { event in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(event.category.color)
                        .frame(width: 4, height: 48)

                    Image(systemName: event.category.icon)
                        .font(.title3)
                        .foregroundStyle(event.category.color)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        HStack(spacing: 4) {
                            Text(event.dateText)
                            Text(event.timeText)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Participant avatars
                    HStack(spacing: -8) {
                        ForEach(event.participants.prefix(3)) { member in
                            Circle()
                                .fill(member.color.opacity(0.3))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text(member.initials)
                                        .font(.system(size: 10))
                                        .fontWeight(.bold)
                                        .foregroundStyle(member.color)
                                )
                        }
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Location Notifications

    private var locationNotificationsCard: some View {
        VStack(spacing: 12) {
            Text("\u{4F4D}\u{7F6E}\u{60C5}\u{5831}\u{901A}\u{77E5}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.locationNotifications) { notification in
                HStack(spacing: 10) {
                    Circle()
                        .fill(notification.member.color.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundStyle(notification.member.color)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(notification.message)
                            .font(.subheadline)
                        Text(notification.timeText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Suggestions

    private var suggestionsCard: some View {
        VStack(spacing: 12) {
            Text("\u{30A4}\u{30D9}\u{30F3}\u{30C8}\u{63D0}\u{6848}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.eventSuggestions) { suggestion in
                HStack(spacing: 12) {
                    Image(systemName: suggestion.icon)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(suggestion.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(suggestion.suggestedSlot.dateText) \(suggestion.suggestedSlot.timeText) (\(suggestion.durationText))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("\u{8FFD}\u{52A0}") {}
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }
}

// MARK: - Components

private struct WeekStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FamilyOverviewView(viewModel: SyncLifeViewModel())
}
