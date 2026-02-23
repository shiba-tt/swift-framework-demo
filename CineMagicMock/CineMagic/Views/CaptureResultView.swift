import SwiftUI

struct CaptureResultView: View {
    let media: CapturedMedia
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [media.filter.color.opacity(0.3), .black.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)

                    VStack(spacing: 8) {
                        Text(media.filter.emoji)
                            .font(.system(size: 48))
                        Text(media.filter.rawValue + "風")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(media.mode == .photo ? "写真を保存しました" : "動画を保存しました")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                // Score
                VStack(spacing: 8) {
                    Text("構図スコア")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: Double(i) < media.compositionScore * 5 ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                        }
                    }
                    .font(.title2)

                    Text(media.scoreLabel)
                        .font(.headline)
                        .foregroundStyle(media.scoreColor)
                }

                // Details
                if let duration = media.duration {
                    HStack(spacing: 20) {
                        detailItem(label: "撮影時間", value: media.formattedDuration)
                        detailItem(label: "フィルター", value: media.filter.rawValue)
                    }
                    let _ = duration
                }

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func detailItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CaptureResultView(
        media: CapturedMedia(
            mode: .photo,
            filter: .wesAnderson,
            compositionScore: 0.85
        )
    )
}
