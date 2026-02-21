import SwiftUI

/// 設定画面
struct SettingsView: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        NavigationStack {
            List {
                // デバイス情報
                Section("デバイス") {
                    HStack {
                        Label("デバイス名", systemImage: "iphone")
                        Spacer()
                        Text(viewModel.deviceName)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("UWB チップ", systemImage: "cpu")
                        Spacer()
                        Text(viewModel.nearbyManager.isUWBSupported ? "U2 (対応)" : "シミュレーション")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("セッション", systemImage: "antenna.radiowaves.left.and.right")
                        Spacer()
                        Text(viewModel.nearbyManager.isSessionActive ? "有効" : "無効")
                            .foregroundStyle(viewModel.nearbyManager.isSessionActive ? .green : .red)
                    }
                }

                // 共有設定
                Section("共有設定") {
                    Toggle(isOn: Binding(
                        get: { viewModel.autoShareEnabled },
                        set: { viewModel.autoShareEnabled = $0 }
                    )) {
                        Label("自動共有モード", systemImage: "bolt.circle.fill")
                    }
                    .tint(.cyan)

                    if viewModel.autoShareEnabled {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                            Text("デバイスを近づけるだけで自動的に共有されます")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Toggle(isOn: Binding(
                        get: { viewModel.hapticsEnabled },
                        set: { viewModel.hapticsEnabled = $0 }
                    )) {
                        Label("触覚フィードバック", systemImage: "hand.tap.fill")
                    }
                    .tint(.cyan)
                }

                // セキュリティ
                Section("セキュリティ") {
                    Label("共有時に確認を求める", systemImage: "lock.shield.fill")
                    Label("ブロックリスト", systemImage: "hand.raised.fill")
                    Label("共有ログの暗号化", systemImage: "lock.doc.fill")
                }

                // UWB 情報
                Section("UWB について") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ultra Wideband (UWB)")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("U1/U2 チップを使用して、近くのデバイスとの距離と方向をセンチメートル精度でリアルタイムに計測します。")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            InfoChip(label: "精度", value: "~10 cm")
                            InfoChip(label: "範囲", value: "~20 m")
                            InfoChip(label: "帯域", value: "5-9 GHz")
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ジェスチャー共有の仕組み")
                            .font(.caption)
                            .fontWeight(.medium)

                        HStack(spacing: 12) {
                            GestureStep(step: 1, title: "近づける", description: "50cm 以内")
                            GestureStep(step: 2, title: "向ける", description: "Z軸 < -0.7")
                            GestureStep(step: 3, title: "共有", description: "自動実行")
                        }
                    }
                    .padding(.vertical, 4)
                }

                // バージョン
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

private struct InfoChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.cyan)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(.cyan.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct GestureStep: View {
    let step: Int
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(.cyan.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text("\(step)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.cyan)
            }
            Text(title)
                .font(.system(size: 10, weight: .medium))
            Text(description)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
