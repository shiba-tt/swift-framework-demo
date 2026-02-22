import SwiftUI

struct SpotDetailView: View {
    let spot: PuzzleSpot

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Map placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .green.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                VStack(spacing: 8) {
                    Image(systemName: "map")
                        .font(.system(size: 36))
                        .foregroundStyle(.blue)

                    Text(spot.name)
                        .font(.headline)

                    Text(
                        String(
                            format: "%.4f, %.4f",
                            spot.latitude,
                            spot.longitude
                        )
                    )
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
            }

            // Spot Info
            VStack(alignment: .leading, spacing: 8) {
                Label("スポット \(spot.spotNumber)", systemImage: "mappin.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.indigo)

                Text(spot.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // Puzzle Preview
            HStack(spacing: 12) {
                Image(systemName: spot.puzzle.type.icon)
                    .font(.title2)
                    .foregroundStyle(spot.puzzle.type.color)
                    .frame(width: 44, height: 44)
                    .background(spot.puzzle.type.color.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(spot.puzzle.type.displayName)
                        .font(.subheadline.bold())

                    HStack(spacing: 2) {
                        ForEach(0..<3) { index in
                            Image(
                                systemName: index < spot.puzzle.difficulty.stars
                                    ? "star.fill" : "star"
                            )
                            .font(.caption2)
                            .foregroundStyle(spot.puzzle.difficulty.color)
                        }
                        Text(spot.puzzle.difficulty.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // NFC Tag ID
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.caption)
                    Text(spot.nfcTagID)
                        .font(.caption2.monospaced())
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
