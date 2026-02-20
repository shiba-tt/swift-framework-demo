import SwiftUI

// MARK: - CookMaster App

/// CookMaster — マルチタイマー料理アシスタント
///
/// AlarmKit を活用した料理タイマーアプリ。
/// 複数のカウントダウンタイマーを同時に管理し、
/// Dynamic Island / ロック画面 / StandBy でリアルタイム表示。
/// サイレントモードを貫通して確実にタイマー完了を通知。
///
/// ## 主要機能
/// - 複数タイマーの同時実行（AlarmKit カウントダウン）
/// - Dynamic Island でのマルチタイマー表示
/// - ロック画面 / StandBy での Live Activity
/// - サイレントモード・集中モード貫通通知
/// - プリセットからのクイックスタート
/// - AppIntents による完了/+1分追加アクション
/// - 一時停止・再開・キャンセル
///
/// ## 技術構成
/// - AlarmKit（iOS 26+）: システムレベルタイマー
/// - ActivityKit: Live Activity / Dynamic Island
/// - WidgetKit: カウントダウン UI
/// - AppIntents: カスタムアクション（完了、+1分追加）
/// - SwiftUI + @Observable: リアクティブ UI
///
/// ## 動作要件
/// - iOS 26.0+
/// - Xcode 26+
/// - NSAlarmKitUsageDescription（Info.plist）
/// - NSSupportsLiveActivities = true（Info.plist）
@main
struct CookMasterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
