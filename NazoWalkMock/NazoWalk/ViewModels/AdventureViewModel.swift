import Foundation
import SwiftData
import SwiftUI

/// まちなか謎解きアドベンチャーのメインビューモデル
@Observable
final class AdventureViewModel {
    static let shared = AdventureViewModel()

    private let spotManager = SpotManager.shared
    private var modelContext: ModelContext?

    // MARK: - State

    var currentProgress: PuzzleProgress?
    var selectedSpot: PuzzleSpot?
    var currentPuzzle: Puzzle?
    var selectedChoiceIndex: Int?
    var isPuzzleSolved = false
    var showingHint = false
    var showingResult = false
    var remainingTime: Int?

    private var timer: Timer?

    var spots: [PuzzleSpot] { spotManager.spots }

    var themeColor: Color { .orange }

    private init() {}

    // MARK: - Setup

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateProgress()
    }

    func requestLocationAuth() {
        spotManager.requestAuthorization()
    }

    // MARK: - Progress

    private func loadOrCreateProgress() {
        guard let modelContext else { return }

        let eventID = "event_2026_spring"
        let descriptor = FetchDescriptor<PuzzleProgress>(
            predicate: #Predicate { $0.eventID == eventID }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            currentProgress = existing
        } else {
            let progress = PuzzleProgress(eventID: eventID)
            modelContext.insert(progress)
            currentProgress = progress
        }
    }

    /// スポットがクリア済みか
    func isSpotCleared(_ spot: PuzzleSpot) -> Bool {
        currentProgress?.isSpotCleared(spot.id) ?? false
    }

    /// 次に挑戦すべきスポット
    var nextSpot: PuzzleSpot? {
        spots.first { !isSpotCleared($0) }
    }

    /// 進捗率（0.0 ~ 1.0）
    var progressRatio: Double {
        guard !spots.isEmpty else { return 0 }
        let cleared = currentProgress?.clearedCount ?? 0
        return Double(cleared) / Double(spots.count)
    }

    /// 全クリアか
    var isAllCleared: Bool {
        currentProgress?.isCompleted ?? false
    }

    // MARK: - Puzzle Actions

    /// スポットを選択して謎解き開始
    func startPuzzle(at spot: PuzzleSpot) {
        selectedSpot = spot
        currentPuzzle = Puzzle.find(by: spot.puzzleID)
        selectedChoiceIndex = nil
        isPuzzleSolved = false
        showingHint = false
        showingResult = false

        // タイマー開始
        if let timeLimit = currentPuzzle?.timeLimitSeconds {
            remainingTime = timeLimit
            startTimer()
        } else {
            remainingTime = nil
        }
    }

    /// 回答を選択
    func selectChoice(_ index: Int) {
        selectedChoiceIndex = index
    }

    /// 回答を確定
    func submitAnswer() {
        guard let puzzle = currentPuzzle,
              let selected = selectedChoiceIndex else { return }

        stopTimer()
        isPuzzleSolved = selected == puzzle.correctIndex
        showingResult = true

        if isPuzzleSolved, let spot = selectedSpot {
            currentProgress?.markSpotCleared(spot.id, points: puzzle.points)

            // 全クリアチェック
            if currentProgress?.clearedCount == spots.count {
                currentProgress?.isCompleted = true
            }
        }
    }

    /// 次のスポットへ移動
    func moveToNextSpot() {
        selectedSpot = nil
        currentPuzzle = nil
        selectedChoiceIndex = nil
        isPuzzleSolved = false
        showingHint = false
        showingResult = false
        remainingTime = nil
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if let remaining = self.remainingTime, remaining > 0 {
                self.remainingTime = remaining - 1
            } else {
                self.stopTimer()
                // 時間切れ
                self.showingResult = true
                self.isPuzzleSolved = false
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
