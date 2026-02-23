import Foundation

/// レシピの各工程
struct RecipeStep: Identifiable, Sendable {
    let id: UUID
    let order: Int
    let instruction: String
    let timerSeconds: Int?

    init(
        id: UUID = UUID(),
        order: Int,
        instruction: String,
        timerSeconds: Int?
    ) {
        self.id = id
        self.order = order
        self.instruction = instruction
        self.timerSeconds = timerSeconds
    }

    var hasTimer: Bool {
        timerSeconds != nil
    }

    var timerText: String? {
        guard let seconds = timerSeconds else { return nil }
        if seconds >= 60 {
            let minutes = seconds / 60
            let secs = seconds % 60
            return secs > 0 ? "\(minutes)分\(secs)秒" : "\(minutes)分"
        }
        return "\(seconds)秒"
    }
}
