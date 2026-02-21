import Foundation
import SwiftUI

/// App Clip 用の軽量ビューモデル
@Observable
final class ClipViewModel {
    static let shared = ClipViewModel()

    var currentSpot: PuzzleSpot?
    var currentPuzzle: Puzzle?
    var selectedChoiceIndex: Int?
    var isPuzzleSolved = false
    var showingResult = false
    var showingHint = false
    var remainingTime: Int?

    private var timer: Timer?

    private init() {}

    /// スポットを読み込み
    func loadSpot(_ spot: PuzzleSpot) {
        currentSpot = spot
        currentPuzzle = Puzzle.find(by: spot.puzzleID)
        selectedChoiceIndex = nil
        isPuzzleSolved = false
        showingResult = false
        showingHint = false

        if let timeLimit = currentPuzzle?.timeLimitSeconds {
            remainingTime = timeLimit
            startTimer()
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
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if let remaining = self.remainingTime, remaining > 0 {
                self.remainingTime = remaining - 1
            } else {
                self.stopTimer()
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
