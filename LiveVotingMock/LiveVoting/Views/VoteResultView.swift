import SwiftUI

struct VoteResultView: View {
    let session: VotingSession

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 56))
                .foregroundStyle(.yellow)

            Text("投票結果")
                .font(.title.bold())

            Text(session.title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Divider()

            VStack(spacing: 12) {
                let sortedOptions = session.options.sorted { $0.voteCount > $1.voteCount }

                ForEach(Array(sortedOptions.enumerated()), id: \.element.id) { index, option in
                    rankRow(option: option, rank: index + 1, totalVotes: session.totalVotes)
                }
            }

            HStack {
                Text("総投票数")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(session.totalVotes.formatted()) 票")
                    .font(.headline)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }

    // MARK: - Rank Row

    private func rankRow(option: VoteOption, rank: Int, totalVotes: Int) -> some View {
        HStack(spacing: 12) {
            rankBadge(rank)

            VStack(alignment: .leading, spacing: 4) {
                Text(option.label)
                    .font(.subheadline.weight(rank == 1 ? .bold : .regular))

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(rank == 1 ? Color.yellow : option.color)
                            .frame(
                                width: proxy.size.width * option.votePercentage(totalVotes: totalVotes) / 100,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }

            VStack(alignment: .trailing) {
                Text("\(Int(option.votePercentage(totalVotes: totalVotes)))%")
                    .font(.subheadline.bold())
                Text("\(option.voteCount.formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50)
        }
    }

    private func rankBadge(_ rank: Int) -> some View {
        Text("\(rank)")
            .font(.caption.bold())
            .foregroundStyle(rank == 1 ? .yellow : rank == 2 ? .gray : .brown)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(rank == 1 ? Color.yellow.opacity(0.2) : Color(.systemGray5))
            )
    }
}
