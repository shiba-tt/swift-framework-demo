import SwiftUI

/// 位置情報権限リクエスト画面
struct LocationPermissionView: View {
    let viewModel: AmeNigeViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "umbrella.fill")
                .font(.system(size: 80))
                .foregroundStyle(.cyan)

            VStack(spacing: 12) {
                Text("AmeNige")
                    .font(.largeTitle.bold())

                Text("分単位のリアルタイム雨よけナビ")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "cloud.rain.fill",
                    title: "分単位降水予報",
                    description: "次の1時間を1分刻みで降水を予測"
                )
                featureRow(
                    icon: "figure.walk",
                    title: "外出判定",
                    description: "今外出して濡れずに帰れるか即座に判定"
                )
                featureRow(
                    icon: "sun.max.fill",
                    title: "晴れ間検出",
                    description: "雨の合間の外出チャンスを自動検出"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                viewModel.requestLocationAccess()
            } label: {
                Text("位置情報へのアクセスを許可")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            .padding(.horizontal, 24)

            Text("降水予報の取得に現在地が必要です")
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
                .foregroundStyle(.cyan)
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
