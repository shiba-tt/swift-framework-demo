import SwiftUI
import SwiftData

@main
struct FocusForgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PomodoroSession.self)
    }
}
