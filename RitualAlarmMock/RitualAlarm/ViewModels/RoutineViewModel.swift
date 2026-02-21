import Foundation
import SwiftUI
import SwiftData

/// ルーティン管理の中心的な ViewModel
@MainActor
@Observable
final class RoutineViewModel {
    // MARK: - Singleton (AppIntents からのアクセス用)

    static let shared = RoutineViewModel()

    // MARK: - State

    /// 現在のステップ
    private(set) var currentStep: RoutineStep?
    /// ルーティンが進行中か
    private(set) var isRunning = false
    /// 一時停止中か
    private(set) var isPaused = false
    /// 残り時間（秒）
    private(set) var remainingSeconds: TimeInterval = 0
    /// 現在のステップの合計時間（秒）
    private(set) var totalSeconds: TimeInterval = 0
    /// 今日の記録
    private(set) var todayRecord: RoutineRecord?

    // MARK: - Dependencies

    let template = RoutineTemplate()
    private let alarmScheduler = RoutineAlarmScheduler.shared
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

    /// ルーティン全体の進捗（完了ステップ数 / 全ステップ数）
    var overallProgress: Double {
        guard let step = currentStep else {
            guard let record = todayRecord else { return 0 }
            return Double(record.completedStepCount) / Double(RoutineStep.totalCount)
        }
        return Double(step.index) / Double(RoutineStep.totalCount)
    }

    /// 現在のステップのテーマカラー
    var themeColor: Color {
        guard let step = currentStep else { return .orange }
        switch step.colorName {
        case "orange": return .orange
        case "green": return .green
        case "yellow": return .yellow
        case "blue": return .blue
        case "purple": return .purple
        default: return .orange
        }
    }

    // MARK: - Setup

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTodayRecord()
    }

    // MARK: - Routine Control

    /// ルーティンを開始（起床ステップから）
    func startRoutine() async {
        guard !isRunning else { return }

        // AlarmKit 認可チェック
        guard await alarmScheduler.requestAuthorization() else {
            print("[RoutineVM] AlarmKit 認可なし")
            return
        }

        // 今日の記録を作成
        let record = RoutineRecord(scheduledWakeUpTime: template.wakeUpTime)
        modelContext?.insert(record)
        try? modelContext?.save()
        todayRecord = record

        // 最初のステップを開始
        await startStep(.wakeUp)
    }

    /// 現在のステップを完了し、次のステップに進む
    func completeCurrentStep() async {
        guard let step = currentStep else { return }
        timerTask?.cancel()

        // 記録を更新
        todayRecord?.markStepCompleted(step)
        try? modelContext?.save()

        // 次のステップがあれば開始
        if let nextStep = step.next {
            await startStep(nextStep)
        } else {
            // 最後のステップ完了
            isRunning = false
            currentStep = nil
            remainingSeconds = 0
            totalSeconds = 0
            print("[RoutineVM] ルーティン完了！")
        }
    }

    /// 現在のステップをスキップして次へ
    func skipCurrentStep() async {
        guard let step = currentStep else { return }
        timerTask?.cancel()

        do {
            try await alarmScheduler.cancelCurrent()
        } catch {
            print("[RoutineVM] アラームキャンセル失敗: \(error)")
        }

        if let nextStep = step.next {
            await startStep(nextStep)
        } else {
            isRunning = false
            currentStep = nil
        }
    }

    /// ルーティン全体を終了
    func endRoutine() async {
        timerTask?.cancel()

        do {
            try await alarmScheduler.cancelCurrent()
        } catch {
            print("[RoutineVM] キャンセル失敗: \(error)")
        }

        isRunning = false
        isPaused = false
        currentStep = nil
        remainingSeconds = 0
        totalSeconds = 0
    }

    /// タイマーを一時停止
    func pause() async {
        guard isRunning, !isPaused else { return }
        isPaused = true
        timerTask?.cancel()

        do {
            try await alarmScheduler.pauseCurrent()
        } catch {
            print("[RoutineVM] 一時停止失敗: \(error)")
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
            print("[RoutineVM] 再開失敗: \(error)")
        }
    }

    // MARK: - Private

    /// ステップを開始
    private func startStep(_ step: RoutineStep) async {
        currentStep = step
        let duration = template.duration(for: step)
        totalSeconds = duration
        remainingSeconds = duration
        isRunning = true
        isPaused = false

        // AlarmKit でアラームをスケジュール
        do {
            try await alarmScheduler.scheduleStep(
                step,
                duration: duration,
                snoozeDuration: template.snoozeDuration
            )
        } catch {
            print("[RoutineVM] アラームスケジュール失敗: \(error)")
        }

        // カウントダウンの場合はローカルタイマーを開始
        if step.isCountdown {
            startLocalTimer()
        }
    }

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
                    self.onTimerComplete()
                    break
                }
            }
        }
    }

    /// タイマー完了時の処理
    private func onTimerComplete() {
        remainingSeconds = 0
    }

    /// 今日の記録をロード
    private func loadTodayRecord() {
        guard let modelContext else { return }

        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<RoutineRecord> { record in
            record.date >= startOfDay
        }
        let descriptor = FetchDescriptor<RoutineRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            let records = try modelContext.fetch(descriptor)
            todayRecord = records.first
        } catch {
            print("[RoutineVM] 記録ロード失敗: \(error)")
        }
    }
}
