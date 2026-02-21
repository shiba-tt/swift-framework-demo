import AppIntents

/// アラーム停止（起きる）の AppIntent
struct WakeUpIntent: AppIntent {
    static var title: LocalizedStringResource = "起きる"
    static var description: IntentDescription = "SleepCraft のアラームを停止して起床を記録します"

    func perform() async throws -> some IntentResult {
        try await SleepAlarmScheduler.shared.stopCurrent()
        SleepMonitor.shared.stopMonitoring()
        return .result()
    }
}

/// スヌーズの AppIntent
struct SnoozeAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "スヌーズ"
    static var description: IntentDescription = "SleepCraft のアラームをスヌーズします"

    func perform() async throws -> some IntentResult {
        // スヌーズは AlarmKit の secondaryButton behavior で自動処理されるため
        // ここでは追加のロジックのみ
        print("[SnoozeAlarmIntent] スヌーズ実行")
        return .result()
    }
}
