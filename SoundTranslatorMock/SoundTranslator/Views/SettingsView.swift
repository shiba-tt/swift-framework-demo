import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SoundTranslatorViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("通知") {
                    Toggle(isOn: $viewModel.hapticEnabled) {
                        Label("触覚フィードバック", systemImage: "iphone.radiowaves.left.and.right")
                    }
                    .tint(.teal)

                    if viewModel.hapticEnabled {
                        ForEach(AlertLevel.allCases, id: \.self) { level in
                            HStack {
                                Image(systemName: level.systemImage)
                                    .foregroundStyle(level.color)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(level.rawValue)
                                        .font(.subheadline)
                                    Text(level.hapticDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Toggle(isOn: $viewModel.watchNotificationEnabled) {
                        Label("Apple Watch 通知", systemImage: "applewatch")
                    }
                    .tint(.teal)
                }

                Section("認識機能") {
                    Toggle(isOn: $viewModel.speechRecognitionEnabled) {
                        Label("会話の文字起こし", systemImage: "text.bubble")
                    }
                    .tint(.teal)

                    Toggle(isOn: $viewModel.autoSummaryEnabled) {
                        Label("AI 自動状況分析", systemImage: "brain.head.profile.fill")
                    }
                    .tint(.teal)
                }

                Section("表示") {
                    Toggle(isOn: $viewModel.liveActivityEnabled) {
                        Label("Live Activity", systemImage: "rectangle.badge.person.crop")
                    }
                    .tint(.teal)
                }

                Section("使用技術") {
                    techInfoRow(
                        title: "SoundAnalysis",
                        desc: "SNClassifySoundRequest で 300 種以上の環境音をリアルタイム分類"
                    )
                    techInfoRow(
                        title: "Core ML (カスタムモデル)",
                        desc: "業務特化の音（工場の機械音、医療機器のアラーム等）を追加認識"
                    )
                    techInfoRow(
                        title: "Speech Framework",
                        desc: "周囲の会話をリアルタイム文字起こし + 翻訳"
                    )
                    techInfoRow(
                        title: "Foundation Models",
                        desc: "複数の音声情報を統合し、状況を自然言語で要約"
                    )
                    techInfoRow(
                        title: "ActivityKit",
                        desc: "検出された音のアイコンとコンテキスト要約を Live Activity で常時表示"
                    )
                }

                Section("アクセシビリティ情報") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("このアプリについて")
                            .font(.headline)
                        Text("聴覚障害者や異文化環境にいる方に「今何が起きているか」をテキストと視覚で伝えるアクセシビリティアプリです。オンデバイスで動作するため、通信環境のない場所でも利用可能です。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("設定")
        }
    }

    private func techInfoRow(title: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
            Text(desc)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView(viewModel: SoundTranslatorViewModel())
}
