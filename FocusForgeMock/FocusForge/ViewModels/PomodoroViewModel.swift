import Foundation
import SwiftUI
import SwiftData

/// ポモドーロタイマーの中心的な ViewModel
@MainActor
@Observable
final class PomodoroViewModel {
    // MARK: - Singleton (AppIntents からのアクセス用)

    static let shared = PomodoroViewModel()

    // MARK: - State

    /// 現在のフェーズ
    private(set) var currentPhase: PomodoroPhase = .work
    /// タイマーが動作中か
    private(set) var isRunning = false
    /// 一時停止中か
    private(set) var isPaused = false
    /// 残り時間（秒）
    private(set) var remainingSeconds: TimeInterval = 0
    /// 今日の完了ポモドーロ数
    private(set) var completedPomodoroCount: Int = 0
    /// 現在のフェーズの合計時間（秒）
    private(set) var totalSeconds: TimeInterval = 0
    /// セッション開始時刻
    private(set) var sessionStartedAt: Date?

    // MARK: - Dependencies

    let settings = PomodoroSettings()
    private let alarmScheduler = AlarmScheduler.shared
    private var timerTask: Task<Void, Never>?
    private var modelContext: ModelContext?

    // MARK: - Computed

    /// 進捗率（0.0 〜 1.0）
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (remainingSeconds / totalSeconds)
    }

    /// 残り時間の表示文字列（mm:ss）
    var remainingTimeText: String {
        let minutes = Int(remainingSeconds) / 60
        let seconds = Int(remainingSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 日次目標の達成率
    var dailyGoalProgress: Double {
        guard settings.dailyGoal > 0 else { return 0 }
        return min(Double(completedPomodoroCount) / Double(settings.dailyGoal), 1.0)
    }

    /// フェーズに応じたテーマカラー
    var themeColor: Color {
        switch currentPhase {
        case .work: .orange
        case .shortBreak: .green
        case .longBreak: .blue
        }
    }

    // MARK: - Setup

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTodayCompletedCount()
    }

    // MARK: - Timer Control

    /// ポモドーロセッションを開始
    func start() async {
        guard !isRunning else { return }

        // AlarmKit 認可チェック
        guard await alarmScheduler.requestAuthorization() else {
            print("[PomodoroVM] AlarmKit 認可なし")
            return
        }

        let duration = settings.duration(for: currentPhase)
        totalSeconds = duration
        remainingSeconds = duration
        isRunning = true
        isPaused = false
        sessionStartedAt = .now

        // AlarmKit でアラームをスケジュール
        do {
            try await alarmScheduler.schedulePomodoro(
                phase: currentPhase,
                duration: duration,
                completedCount: completedPomodoroCount,
                dailyGoal: settings.dailyGoal
            )
        } catch {
            print("[PomodoroVM] アラームスケジュール失敗: \(error)")
        }

        // ローカルタイマー（UI 更新用）
        startLocalTimer()
    }

    /// タイマーを一時停止
    func pause() async {
        guard isRunning, !isPaused else { return }
        isPaused = true
        timerTask?.cancel()

        do {
            try await alarmScheduler.pauseCurrent()
        } catch {
            print("[PomodoroVM] 一時停止失敗: \(error)")
        }
    }

    /// タイマーを再開
    func resume() async {
        guard isRunning, isPaused else { return }
        isPaused = false
        startLocalTimer()

        do {
            try await alarmScheduler.resumeCurrent()
        } catch {
            print("[PomodoroVM] 再開失敗: \(error)")
        }
    }

    /// セッションを終了（リセット）
    func endSession() async {
        timerTask?.cancel()

        do {
            try await alarmScheduler.cancelCurrent()
        } catch {
            print("[PomodoroVM] キャンセル失敗: \(error)")
        }

        isRunning = false
        isPaused = false
        currentPhase = .work
        remainingSeconds = settings.duration(for: .work)
        totalSeconds = remainingSeconds
        sessionStartedAt = nil
    }

    /// 作業フェーズ完了 → 休憩フェーズに移行
    func transitionToBreak() async {
        timerTask?.cancel()
        recordSession(phase: .work, completed: true)
        completedPomodoroCount += 1

        // 長い休憩か短い休憩かを判定
        if completedPomodoroCount % settings.longBreakInterval == 0 {
            currentPhase = .longBreak
        } else {
            currentPhase = .shortBreak
        }

        isRunning = false
        isPaused = false

        if settings.autoStartNextPhase {
            await start()
        } else {
            remainingSeconds = settings.duration(for: currentPhase)
            totalSeconds = remainingSeconds
        }
    }

    /// 休憩フェーズ完了 → 作業フェーズに移行
    func transitionToWork() async {
        timerTask?.cancel()
        recordSession(phase: currentPhase, completed: true)

        currentPhase = .work
        isRunning = false
        isPaused = false

        if settings.autoStartNextPhase {
            await start()
        } else {
            remainingSeconds = settings.duration(for: .work)
            totalSeconds = remainingSeconds
        }
    }

    // MARK: - Private

    /// ローカルタイマー（UI カウントダウン更新用）
    private func startLocalTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                guard let self, self.isRunning, !self.isPaused else { break }

                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    // カウントダウン完了 — AlarmKit がアラートを表示する
                    // ここでは UI 状態のみ更新
                    self.onTimerComplete()
                    break
                }
            }
        }
    }

    /// タイマー完了時の処理
    private func onTimerComplete() {
        isRunning = false
        isPaused = false
        remainingSeconds = 0
    }

    /// セッション記録を SwiftData に保存
    private func recordSession(phase: PomodoroPhase, completed: Bool) {
        guard let modelContext else { return }

        let session = PomodoroSession(
            phase: phase,
            startedAt: sessionStartedAt ?? .now,
            durationSeconds: Int(settings.duration(for: phase)),
            isCompleted: completed
        )
        session.endedAt = .now

        modelContext.insert(session)
        try? modelContext.save()
    }

    /// 今日の完了ポモドーロ数をロード
    private func loadTodayCompletedCount() {
        guard let modelContext else { return }

        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<PomodoroSession> { session in
            session.phase == "work" && session.isCompleted && session.startedAt >= startOfDay
        }
        let descriptor = FetchDescriptor<PomodoroSession>(predicate: predicate)

        do {
            let sessions = try modelContext.fetch(descriptor)
            completedPomodoroCount = sessions.count
        } catch {
            print("[PomodoroVM] 履歴ロード失敗: \(error)")
        }
    }
}
