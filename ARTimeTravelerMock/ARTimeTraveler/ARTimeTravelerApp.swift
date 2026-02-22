import SwiftUI

@main
struct ARTimeTravelerApp: App {
    @State private var appClipManager = AppClipManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(
                    NSUserActivityTypeBrowsingWeb
                ) { activity in
                    guard let url = activity.webpageURL else { return }
                    appClipManager.handleIncomingURL(url)
                }
        }
    }
}
