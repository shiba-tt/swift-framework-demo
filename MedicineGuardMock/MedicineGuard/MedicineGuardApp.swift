import SwiftUI
import SwiftData

@main
struct MedicineGuardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Medication.self, MedicationRecord.self])
    }
}
