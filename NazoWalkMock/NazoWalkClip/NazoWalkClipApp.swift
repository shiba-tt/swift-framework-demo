import SwiftUI

/// App Clip のエントリーポイント
/// NFC タグや QR コードをスキャンすると、該当スポットの謎解きが直接起動する
@main
struct NazoWalkClipApp: App {
    @State private var spotManager = SpotManager.shared

    var body: some Scene {
        WindowGroup {
            ClipContentView()
                .onContinueUserActivity(
                    NSUserActivityTypeBrowsingWeb,
                    perform: handleUserActivity
                )
        }
    }

    /// App Clip 起動 URL からスポットを特定
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL,
              let spot = spotManager.findSpot(from: url) else {
            return
        }
        // スポットの謎解きを直接開始
        ClipViewModel.shared.loadSpot(spot)
    }
}
