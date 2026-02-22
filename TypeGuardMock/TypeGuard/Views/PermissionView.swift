import SwiftUI

/// SensorKit のアクセス許可を求めるビュー
struct PermissionView: View {
    let viewModel: TypeGuardViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // アイコン
            Image(systemName: "keyboard.badge.eye.fill")
                .font(.system(size: 64))
                .foregroundStyle(.teal.gradient)

            // タイトル
            VStack(spacing: 8) {
                Text("TypeGuard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("タイピングで見つける神経疾患の兆候")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // 研究説明
            VStack(alignment: .leading, spacing: 4) {
                Text("この研究アプリについて")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text("TypeGuard は SensorKit のキーボードメトリクスを活用し、日常のタイピングパターンからパーキンソン病や認知機能低下の早期兆候を検出する研究アプリです。追加の操作なしに受動的にデータを収集します。")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)

            // 機能一覧
            VStack(alignment: .leading, spacing: 14) {
                FeatureRow(
                    icon: "keyboard.fill",
                    title: "キーストローク分析",
                    description: "タイピング速度・エラー率・リズムを継続的に追跡"
                )
                FeatureRow(
                    icon: "waveform.path.ecg",
                    title: "振戦検出",
                    description: "隣接キー誤入力パターンから微細な振戦を検出"
                )
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "長期トレンド",
                    description: "数ヶ月〜年単位の緩やかな変化を追跡"
                )
                FeatureRow(
                    icon: "shield.checkered",
                    title: "ベースライン学習",
                    description: "あなたの「普段」を学習し、変化を検出"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            // 許可ボタン
            Button {
                Task { await viewModel.initialize() }
            } label: {
                Text("研究に参加する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.teal.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.teal)
                .frame(width: 36, height: 36)
                .background(.teal.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
