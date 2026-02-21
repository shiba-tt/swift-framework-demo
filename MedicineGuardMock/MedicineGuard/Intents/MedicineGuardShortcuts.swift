import AppIntents

/// MedicineGuard の AppShortcuts 定義
/// Siri / Shortcuts アプリからアクセス可能
struct MedicineGuardShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TakeMedicationIntent(),
            phrases: [
                "薬を飲んだ",
                "\(.applicationName) で服薬を記録",
                "\(.applicationName) で薬を飲んだことを記録"
            ],
            shortTitle: "服薬記録",
            systemImageName: "pills.fill"
        )
    }
}
