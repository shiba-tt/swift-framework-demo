import Foundation

/// リアルタイムの音分類結果
struct SoundClassification: Identifiable, Sendable {
    let id: UUID
    let category: SoundCategory
    let confidence: Double
    let timestamp: Date

    init(id: UUID = UUID(), category: SoundCategory, confidence: Double, timestamp: Date = .now) {
        self.id = id
        self.category = category
        self.confidence = confidence
        self.timestamp = timestamp
    }
}
