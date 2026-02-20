import AlarmKit
import Observation
import SwiftUI

// MARK: - タイマー ViewModel

/// アプリ全体のタイマー状態を管理する ViewModel
@Observable
@MainActor
final class TimerViewModel {

    // MARK: - Published Properties

    /// アクティブなタイマー一覧
    var activeTimers: [CookingTimer] = []

    /// 完了したタイマーの履歴
    var completedTimers: [CookingTimer] = []

    /// AlarmKit 認可状態
    var isAuthorized = false

    /// エラーメッセージ
    var errorMessage: String?

    /// タイマー追加シートの表示状態
    var showingAddTimer = false

    /// プリセット選択シートの表示状態
    var showingPresetSelection = false

    /// 選択中のタイマー（詳細表示）
    var selectedTimer: CookingTimer?

    // MARK: - Private Properties

    private let alarmManager = CookingAlarmManager.shared

    /// 表示更新用タイマー（1秒ごと）
    private var displayTimer: Timer?

    // MARK: - Computed Properties

    /// アクティブなタイマーの数
    var activeTimerCount: Int {
        activeTimers.filter { $0.state == .counting || $0.state == .paused }.count
    }

    /// カウントダウン中のタイマー
    var countingTimers: [CookingTimer] {
        activeTimers.filter { $0.state == .counting }
    }

    /// 一時停止中のタイマー
    var pausedTimers: [CookingTimer] {
        activeTimers.filter { $0.state == .paused }
    }

    /// アラート中（完了）のタイマー
    var alertingTimers: [CookingTimer] {
        activeTimers.filter { $0.state == .alerting }
    }

    // MARK: - Initialization

    init() {}

    // MARK: - セットアップ

    /// 初期化処理：認可チェック & アラーム監視開始
    func setup() async {
        isAuthorized = await alarmManager.requestAuthorization()

        if isAuthorized {
            startDisplayTimer()
            await observeAlarms()
        }
    }

    // MARK: - タイマー操作

    /// 新しいタイマーを開始
    func startTimer(_ timer: CookingTimer) async {
        var newTimer = timer
        newTimer.startedAt = Date()
        newTimer.state = .counting

        do {
            try await alarmManager.scheduleTimer(newTimer)
            activeTimers.append(newTimer)
            errorMessage = nil
        } catch {
            errorMessage = "タイマーの開始に失敗しました: \(error.localizedDescription)"
        }
    }

    /// プリセットからタイマーを開始
    func startFromPreset(_ preset: TimerPreset) async {
        let timer = preset.toCookingTimer()
        await startTimer(timer)
    }

    /// カスタムタイマーを作成して開始
    func startCustomTimer(
        name: String,
        category: CookingCategory,
        minutes: Int,
        seconds: Int
    ) async {
        let duration = TimeInterval(minutes * 60 + seconds)
        guard duration > 0 else {
            errorMessage = "タイマー時間を設定してください"
            return
        }

        let timer = CookingTimer(
            name: name.isEmpty ? "\(category.displayName)タイマー" : name,
            category: category,
            duration: duration
        )
        await startTimer(timer)
    }

    /// タイマーを一時停止
    func pauseTimer(_ timer: CookingTimer) async {
        await alarmManager.pauseTimer(id: timer.id)
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id }) {
            activeTimers[index].pausedRemainingTime = activeTimers[index].remainingTime
            activeTimers[index].state = .paused
        }
    }

    /// タイマーを再開
    func resumeTimer(_ timer: CookingTimer) async {
        await alarmManager.resumeTimer(id: timer.id)
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id }) {
            // 再開時に startedAt を再計算
            let remaining = activeTimers[index].pausedRemainingTime ?? activeTimers[index].duration
            activeTimers[index].startedAt = Date().addingTimeInterval(-( activeTimers[index].duration - remaining))
            activeTimers[index].pausedRemainingTime = nil
            activeTimers[index].state = .counting
        }
    }

    /// タイマーを停止（完了）
    func stopTimer(_ timer: CookingTimer) async {
        await alarmManager.stopTimer(id: timer.id)
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id }) {
            activeTimers[index].state = .stopped
            completedTimers.append(activeTimers[index])
            activeTimers.remove(at: index)
        }
    }

    /// タイマーをキャンセル
    func cancelTimer(_ timer: CookingTimer) async {
        await alarmManager.cancelTimer(id: timer.id)
        activeTimers.removeAll { $0.id == timer.id }
    }

    /// すべてのタイマーをキャンセル
    func cancelAllTimers() async {
        for timer in activeTimers {
            await alarmManager.cancelTimer(id: timer.id)
        }
        activeTimers.removeAll()
    }

    // MARK: - AlarmKit 監視

    /// AlarmKit のアラーム状態変更を監視
    private func observeAlarms() async {
        for await alarm in alarmManager.activeAlarms {
            handleAlarmUpdate(alarm)
        }
    }

    /// アラーム状態の更新をハンドル
    private func handleAlarmUpdate(_ alarm: Alarm) {
        guard let index = activeTimers.firstIndex(where: { $0.id == alarm.id }) else {
            return
        }

        switch alarm.state {
        case .alerting:
            activeTimers[index].state = .alerting
        case .stopped:
            activeTimers[index].state = .stopped
            completedTimers.append(activeTimers[index])
            activeTimers.remove(at: index)
        default:
            break
        }
    }

    // MARK: - 表示更新タイマー

    /// 1秒ごとに UI を更新するタイマーを開始
    private func startDisplayTimer() {
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateTimerDisplays()
            }
        }
    }

    /// タイマー表示を更新（残り時間が 0 になったタイマーをアラート状態に遷移）
    private func updateTimerDisplays() {
        for index in activeTimers.indices {
            if activeTimers[index].state == .counting && activeTimers[index].remainingTime <= 0 {
                activeTimers[index].state = .alerting
            }
        }
        // @Observable により自動的に View が更新される
    }

    deinit {
        displayTimer?.invalidate()
    }
}
