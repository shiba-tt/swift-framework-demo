import SwiftUI
import SwiftData

@main
struct RitualAlarmApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: RoutineRecord.self)
    }
}
