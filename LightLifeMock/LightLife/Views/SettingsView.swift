import SwiftUI

struct SettingsView: View {
    let viewModel: LightLifeViewModel
    @State private var showResearchInfo = false

    var body: some View {
        NavigationStack {
            List {
                Section("センサー制御") {
                    Button {
                        viewModel.toggleRecording()
                    } label: {
                        Label(
                            viewModel.isRecording ? "記録を停止" : "記録を開始",
                            systemImage: viewModel.isRecording ? "stop.circle.fill" : "record.circle"
                        )
                    }

                    HStack {
                        Text("認可状態")
                        Spacer()
                        Text(viewModel.isAuthorized ? "承認済み" : "未承認")
                            .foregroundStyle(.secondary)
                    }

                    if !viewModel.isAuthorized {
                        Button("SensorKit 認可をリクエスト") {
                            viewModel.requestAuthorization()
                        }
                    }
                }

                Section("収集データ") {
                    sensorRow(name: "環境光センサー", sensor: "ambientLightSensor", icon: "light.beacon.max.fill")
                    sensorRow(name: "訪問場所", sensor: "visits", icon: "mappin.circle.fill")
                    sensorRow(name: "デバイス使用レポート", sensor: "deviceUsageReport", icon: "iphone")
                }

                Section("研究情報") {
                    Button {
                        showResearchInfo = true
                    } label: {
                        Label("研究プロトコルについて", systemImage: "doc.text.fill")
                    }

                    HStack {
                        Text("データ保持期間")
                        Spacer()
                        Text("24 時間遅延")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("IRB 承認番号")
                        Spacer()
                        Text("DEMO-2025-001")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("フレームワーク")
                        Spacer()
                        Text("SensorKit")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("対応 OS")
                        Spacer()
                        Text("iOS 18.0+")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showResearchInfo) {
                researchInfoSheet
            }
        }
    }

    private func sensorRow(name: String, sensor: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                Text(sensor)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }

    private var researchInfoSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("LightLife 研究プロトコル")
                        .font(.title2.bold())

                    Text("本アプリは、光環境と概日リズムの関係を研究するためのツールです。")
                        .font(.body)

                    Group {
                        sectionHeader("収集するデータ")
                        Text("- 環境光（照度・色温度）\n- 訪問場所（カテゴリ・滞在時間）\n- デバイス使用状況（画面使用時間）")

                        sectionHeader("プライバシー保護")
                        Text("- GPS 座標は収集しません\n- 訪問場所はカテゴリのみ記録\n- 24 時間のホールディング期間\n- すべてのデータはデバイス上で処理")

                        sectionHeader("研究目的")
                        Text("- 季節性感情障害（SAD）の予防研究\n- 睡眠障害と光環境の相関分析\n- 概日リズム維持のための介入研究")
                    }
                    .font(.body)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { showResearchInfo = false }
                }
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 8)
    }
}
