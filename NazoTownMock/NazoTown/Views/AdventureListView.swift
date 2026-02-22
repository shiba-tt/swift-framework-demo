import SwiftUI

struct AdventureListView: View {
    @Bindable var viewModel: NazoTownViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerBanner

                    ForEach(viewModel.availableAdventures) { adventure in
                        adventureCard(adventure)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("まちなか謎解き")
        }
    }

    // MARK: - Header

    private var headerBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48))
                .foregroundStyle(.white)

            Text("まちなか謎解きアドベンチャー")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("NFCタグをタップしてパズルを解こう")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Adventure Card

    private func adventureCard(_ adventure: Adventure) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(adventure.title)
                        .font(.headline)

                    Text(adventure.areaName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                statusBadge(adventure.status)
            }

            Text(adventure.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack(spacing: 16) {
                Label("\(adventure.spots.count)スポット", systemImage: "mappin.circle")
                Label("\(adventure.timeLimitMinutes)分", systemImage: "clock")

                Spacer()

                if adventure.status == .notStarted {
                    Button {
                        viewModel.startAdventure(adventure)
                    } label: {
                        Text("スタート")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(.indigo)
                            .clipShape(Capsule())
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if adventure.status == .inProgress {
                ProgressView(value: adventure.progressRatio)
                    .tint(.indigo)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Status Badge

    private func statusBadge(_ status: AdventureStatus) -> some View {
        Text(status.displayName)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(status).opacity(0.15))
            .foregroundStyle(statusColor(status))
            .clipShape(Capsule())
    }

    private func statusColor(_ status: AdventureStatus) -> Color {
        switch status {
        case .notStarted: .secondary
        case .inProgress: .blue
        case .completed: .green
        case .expired: .red
        }
    }
}
