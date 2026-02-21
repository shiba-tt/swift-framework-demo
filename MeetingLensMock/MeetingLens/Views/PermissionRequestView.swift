import SwiftUI

/// カレンダーアクセス許可リクエスト画面
struct PermissionRequestView: View {
    let viewModel: MeetingLensViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            VStack(spacing: 12) {
                Text("MeetingLens")
                    .font(.largeTitle.bold())

                Text("会議コストを可視化し、\n時間の使い方を最適化します")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "yensign.circle.fill",
                    color: .orange,
                    title: "会議コストの金額換算",
                    description: "参加者数×時間で会議のコストを可視化"
                )
                featureRow(
                    icon: "chart.bar.fill",
                    color: .blue,
                    title: "時間帯ヒートマップ",
                    description: "会議の集中する時間帯を一目で把握"
                )
                featureRow(
                    icon: "lightbulb.fill",
                    color: .yellow,
                    title: "最適化提案",
                    description: "ディープワーク時間を増やす改善案"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                Task {
                    await viewModel.requestAccess()
                }
            } label: {
                Text("カレンダーへのアクセスを許可")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func featureRow(
        icon: String,
        color: Color,
        title: String,
        description: String
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
