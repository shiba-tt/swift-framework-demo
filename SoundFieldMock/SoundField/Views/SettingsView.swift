import SwiftUI

/// 設定画面
struct SettingsView: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        NavigationStack {
            List {
                // セッション情報
                Section("セッション") {
                    HStack {
                        Label("モード", systemImage: viewModel.audioManager.sessionMode.icon)
                        Spacer()
                        Picker("", selection: Binding(
                            get: { viewModel.audioManager.sessionMode },
                            set: { viewModel.audioManager.sessionMode = $0 }
                        )) {
                            ForEach(SessionMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }

                    HStack {
                        Label("UWB ステータス", systemImage: "antenna.radiowaves.left.and.right")
                        Spacer()
                        Text(viewModel.audioManager.isUWBSupported ? "対応" : "シミュレーション")
                            .font(.caption)
                            .foregroundStyle(viewModel.audioManager.isUWBSupported ? .green : .orange)
                    }

                    HStack {
                        Label("セッション", systemImage: "wifi")
                        Spacer()
                        Text(viewModel.audioManager.isSessionActive ? "アクティブ" : "停止中")
                            .font(.caption)
                            .foregroundStyle(viewModel.audioManager.isSessionActive ? .green : .secondary)
                    }

                    HStack {
                        Label("接続リスナー", systemImage: "person.2.fill")
                        Spacer()
                        Text("\(viewModel.audioManager.listeners.count) 人")
                            .font(.system(size: 12, design: .monospaced))
                    }
                }

                // ゾーン設定
                Section("サウンドゾーン") {
                    ForEach([SoundZone.intimate, .near, .mid, .far], id: \.rawValue) { zone in
                        HStack {
                            Circle()
                                .fill(zone.color)
                                .frame(width: 10, height: 10)
                            Text(zone.displayName)
                                .font(.subheadline)
                            Spacer()
                            Text(zone.effectDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // 情報
                Section("情報") {
                    HStack {
                        Label("バージョン", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("フレームワーク", systemImage: "shippingbox")
                        Spacer()
                        Text("Nearby Interaction + AVFoundation")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
