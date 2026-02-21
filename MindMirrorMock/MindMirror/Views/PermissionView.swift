import SwiftUI

/// SensorKit のアクセス許可を求めるビュー
struct PermissionView: View {
    let viewModel: MindMirrorViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // アイコン
            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple.gradient)

            // タイトル
            VStack(spacing: 8) {
                Text("MindMirror")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("日常行動からメンタルヘルスを見守る")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // 研究説明
            VStack(alignment: .leading, spacing: 4) {
                Text("この研究アプリについて")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text("MindMirror は Apple の SensorKit を活用し、日常のデバイス使用パターンからメンタルヘルスの変化を検出する研究アプリです。すべてのデータはデバイス上で処理され、プライバシーが保護されます。")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)

            // センサー一覧
            VStack(alignment: .leading, spacing: 14) {
                SensorFeatureRow(
                    icon: "keyboard.fill",
                    title: "キーボードメトリクス",
                    description: "タイピングパターンから認知機能の変化を追跡"
                )
                SensorFeatureRow(
                    icon: "iphone",
                    title: "デバイス使用",
                    description: "画面使用パターンと生活リズムを分析"
                )
                SensorFeatureRow(
                    icon: "message.fill",
                    title: "コミュニケーション",
                    description: "社会的つながりの変化を検出"
                )
                SensorFeatureRow(
                    icon: "sun.max.fill",
                    title: "環境光",
                    description: "光環境と概日リズムの関係を分析"
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
                    .background(.purple.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

private struct SensorFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 36, height: 36)
                .background(.purple.opacity(0.1))
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
