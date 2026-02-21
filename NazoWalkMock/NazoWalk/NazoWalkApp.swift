import SwiftUI
import SwiftData

@main
struct NazoWalkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PuzzleProgress.self)
    }
}
