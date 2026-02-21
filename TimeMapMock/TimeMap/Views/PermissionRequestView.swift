import SwiftUI

/// カレンダー権限リクエスト画面
struct PermissionRequestView: View {
    let viewModel: TimeMapViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "map.fill")
                .font(.system(size: 80))
                .foregroundStyle(.indigo)

            VStack(spacing: 12) {
                Text("TimeMap")
                    .font(.largeTitle.bold())

                Text("カレンダーの予定を地図上に\n時系列で可視化")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "mappin.and.ellipse",
                    title: "時空間マップ",
                    description: "予定を地図上に時系列でプロット"
                )
                featureRow(
                    icon: "arrow.triangle.turn.up.right.diamond",
                    title: "移動ルート計算",
                    description: "イベント間の移動時間を自動計算"
                )
                featureRow(
                    icon: "clock.badge.checkmark",
                    title: "空き時間活用",
                    description: "空き時間に合ったアクティビティを提案"
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
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .padding(.horizontal, 24)

            Text("予定データは端末内でのみ処理されます")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()
                .frame(height: 20)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 36)

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
