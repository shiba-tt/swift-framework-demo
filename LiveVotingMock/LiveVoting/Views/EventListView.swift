import SwiftUI

struct EventListView: View {
    @Bindable var viewModel: LiveVotingViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerBanner
                    participantBanner

                    ForEach(viewModel.activeEvents) { event in
                        eventCard(event)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ライブ投票")
        }
    }

    // MARK: - Header

    private var headerBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)

            Text("ライブ投票・インタラクション")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("NFCタグをタップして投票に参加しよう")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [.orange, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Participant Banner

    private var participantBanner: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundStyle(.blue)
            Text("現在の参加者数")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(viewModel.participantCount.formatted())人")
                .font(.headline)
                .foregroundStyle(.blue)
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.participantCount)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Event Card

    private func eventCard(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.eventType.icon)
                    .font(.title2)
                    .foregroundStyle(event.eventType.color)
                    .frame(width: 44, height: 44)
                    .background(event.eventType.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)

                    Text(event.venue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                statusBadge(event.status)
            }

            Divider()

            HStack(spacing: 16) {
                Label(event.eventType.displayName, systemImage: event.eventType.icon)
                Label("\(event.activeSessions.count)セッション", systemImage: "list.bullet")
                Label("\(event.totalParticipants.formatted())票", systemImage: "chart.bar.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Button {
                viewModel.selectEvent(event)
            } label: {
                Text("参加する")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(event.eventType.color)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Status Badge

    private func statusBadge(_ status: EventStatus) -> some View {
        HStack(spacing: 4) {
            if status == .live {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
            }
            Text(status.displayName)
        }
        .font(.caption2.bold())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status == .live ? Color.red.opacity(0.15) : Color.secondary.opacity(0.15))
        .foregroundStyle(status == .live ? .red : .secondary)
        .clipShape(Capsule())
    }
}
