import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: KakeiboViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("予算設定") {
                    HStack {
                        Text("月間予算")
                        Spacer()
                        Text("¥\(viewModel.formatted(viewModel.budget.monthlyLimit))")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Siri & Shortcuts") {
                    Label("「支出を記録」で金額を記録", systemImage: "mic")
                    Label("「今月の支出は？」で合計確認", systemImage: "magnifyingglass")
                    Label("「かんたん記録」でテキスト入力", systemImage: "text.badge.plus")
                }

                Section("Spotlight 連携") {
                    Label("Spotlight から支出を検索", systemImage: "magnifyingglass")
                    Label("インタラクティブスニペットで即記録", systemImage: "rectangle.badge.plus")
                }

                Section("ウィジェット") {
                    Label("今月のサマリーをホーム画面に", systemImage: "square.grid.2x2")
                    Label("ロック画面に今日の支出を表示", systemImage: "lock.circle")
                }

                Section("Control Center") {
                    Label("「支出を記録」ボタンを追加可能", systemImage: "switch.2")
                }

                Section("このアプリについて") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("フレームワーク")
                        Spacer()
                        Text("App Intents")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("対応 iOS")
                        Spacer()
                        Text("iOS 18.0+")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
