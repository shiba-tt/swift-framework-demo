import Foundation
import SwiftData

/// ポモドーロセッションの記録モデル
@Model
final class PomodoroSession {
    var id: UUID
    var phase: String  // PomodoroPhase.rawValue
    var startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        phase: PomodoroPhase,
        startedAt: Date = .now,
        durationSeconds: Int,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.phase = phase.rawValue
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.isCompleted = isCompleted
    }

    var pomodoroPhase: PomodoroPhase {
        PomodoroPhase(rawValue: phase) ?? .work
    }
}
