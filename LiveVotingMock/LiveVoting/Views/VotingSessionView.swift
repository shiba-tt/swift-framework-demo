import SwiftUI

struct VotingSessionView: View {
    @Bindable var viewModel: LiveVotingViewModel
    let event: Event

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    eventHeader

                    ForEach(event.activeSessions) { session in
                        sessionCard(session)
                    }

                    let closedSessions = event.sessions.filter { $0.status == .results }
                    if !closedSessions.isEmpty {
                        Section {
                            ForEach(closedSessions) { session in
                                resultCard(session)
                            }
                        } header: {
                            HStack {
                                Text("結果発表済み")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(event.title)
        }
    }

    // MARK: - Event Header

    private var eventHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.venue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("投票セッション: \(event.activeSessions.count)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("累計投票数")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(event.totalParticipants.formatted())
                    .font(.title3.bold())
                    .foregroundStyle(event.eventType.color)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Session Card

    private func sessionCard(_ session: VotingSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: session.sessionType.icon)
                    .foregroundStyle(event.eventType.color)
                Text(session.title)
                    .font(.headline)
                Spacer()
                Text(session.sessionType.displayName)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(event.eventType.color.opacity(0.15))
                    .foregroundStyle(event.eventType.color)
                    .clipShape(Capsule())
            }

            Text(session.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            let hasVoted = viewModel.hasVoted(session: session)

            ForEach(session.options) { option in
                optionRow(option, session: session, hasVoted: hasVoted)
            }

            if !hasVoted {
                Text("タップして投票してください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            HStack {
                Text("合計 \(session.totalVotes.formatted()) 票")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if hasVoted {
                    Label("投票済み", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Option Row

    private func optionRow(_ option: VoteOption, session: VotingSession, hasVoted: Bool) -> some View {
        Button {
            guard !hasVoted else { return }
            viewModel.selectSession(session)
            viewModel.selectOption(option.id)
            viewModel.submitVote()
        } label: {
            VStack(spacing: 6) {
                HStack {
                    Text(option.label)
                        .font(.subheadline.weight(hasVoted ? .semibold : .regular))
                        .foregroundStyle(.primary)

                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if hasVoted {
                        Text("\(Int(viewModel.votePercentage(option: option, in: session)))%")
                            .font(.subheadline.bold())
                            .foregroundStyle(option.color)
                    }
                }

                if hasVoted {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(option.color)
                                .frame(
                                    width: proxy.size.width * viewModel.votePercentage(option: option, in: session) / 100,
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(hasVoted ? Color.clear : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(hasVoted)
    }

    // MARK: - Result Card

    private func resultCard(_ session: VotingSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                Text(session.title)
                    .font(.headline)
                Spacer()
                Text("結果発表")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            }

            if let winner = session.leadingOption {
                HStack {
                    Text("1位")
                        .font(.caption.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.yellow.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Text(winner.label)
                        .font(.subheadline.bold())

                    Spacer()

                    Text("\(winner.voteCount.formatted()) 票")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
