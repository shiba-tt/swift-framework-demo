import SwiftUI
import SwiftData

@main
struct SleepCraftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SleepRecord.self)
    }
}
