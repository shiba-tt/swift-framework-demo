import AppIntents
import AlarmKit

// MARK: - タイマー完了 Intent

/// タイマーの「完了」ボタンがタップされた時に実行される AppIntent
struct CompleteCookingTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "料理タイマー完了"
    static var description: IntentDescription = "料理タイマーを完了としてマークします"

    @Parameter(title: "タイマーID")
    var timerID: String

    init() {}

    init(timerID: String) {
        self.timerID = timerID
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: timerID) else {
            return .result()
        }
        // タイマーの完了を記録
        await CookingTimerStore.shared.markCompleted(id: uuid)
        return .result()
    }
}

// MARK: - 1分追加 Intent

/// タイマーの「+1分追加」ボタンがタップされた時に実行される AppIntent
/// postAlert カウントダウンで1分の延長を実現
struct ExtendCookingTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "1分追加"
    static var description: IntentDescription = "料理タイマーに1分追加します"

    @Parameter(title: "タイマーID")
    var timerID: String

    init() {}

    init(timerID: String) {
        self.timerID = timerID
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: timerID) else {
            return .result()
        }
        // タイマーに1分追加（新しいカウントダウンタイマーとしてリスケジュール）
        await CookingTimerStore.shared.extendTimer(id: uuid, additionalSeconds: 60)
        return .result()
    }
}

// MARK: - 一時停止 Intent

/// Dynamic Island / ロック画面から直接一時停止する AppIntent
struct PauseCookingTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "タイマー一時停止"
    static var description: IntentDescription = "料理タイマーを一時停止します"

    @Parameter(title: "タイマーID")
    var timerID: String

    init() {}

    init(timerID: String) {
        self.timerID = timerID
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: timerID) else {
            return .result()
        }
        await CookingAlarmManager.shared.pauseTimer(id: uuid)
        return .result()
    }
}

// MARK: - キャンセル Intent

/// タイマーをキャンセルする AppIntent
struct CancelCookingTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "タイマーキャンセル"
    static var description: IntentDescription = "料理タイマーをキャンセルします"

    @Parameter(title: "タイマーID")
    var timerID: String

    init() {}

    init(timerID: String) {
        self.timerID = timerID
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: timerID) else {
            return .result()
        }
        await CookingAlarmManager.shared.cancelTimer(id: uuid)
        return .result()
    }
}

// MARK: - タイマーストア（Intent から参照）

/// AppIntent から参照される タイマー状態管理シングルトン
/// ViewModel とは別に、バックグラウンドでも動作する永続ストア
actor CookingTimerStore {
    static let shared = CookingTimerStore()

    private init() {}

    /// タイマーを完了としてマーク
    func markCompleted(id: UUID) {
        // UserDefaults や SwiftData で完了記録を永続化
        let key = "timer_completed_\(id.uuidString)"
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)

        // 完了回数のインクリメント
        let countKey = "timer_total_completed"
        let current = UserDefaults.standard.integer(forKey: countKey)
        UserDefaults.standard.set(current + 1, forKey: countKey)
    }

    /// タイマーに時間を追加
    func extendTimer(id: UUID, additionalSeconds: TimeInterval) {
        // CookingAlarmManager 経由で再スケジュール
        Task {
            await CookingAlarmManager.shared.extendTimer(
                id: id,
                additionalSeconds: additionalSeconds
            )
        }
    }
}
