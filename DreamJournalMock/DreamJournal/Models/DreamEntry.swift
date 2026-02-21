import Foundation
import SwiftData

// MARK: - DreamEntry（夢の記録）

@Model
final class DreamEntry {
    var id: UUID
    var recordedAt: Date
    var rawTranscription: String
    var title: String?
    var narrative: String?
    var themes: [String]
    var emotionalToneRawValue: String?
    var symbols: [DreamSymbolData]
    var lucidity: Int // 1-5: 明晰度
    var vividness: Int // 1-5: 鮮明度
    var isAnalyzed: Bool

    init(
        rawTranscription: String,
        recordedAt: Date = .now,
        lucidity: Int = 3,
        vividness: Int = 3
    ) {
        self.id = UUID()
        self.recordedAt = recordedAt
        self.rawTranscription = rawTranscription
        self.title = nil
        self.narrative = nil
        self.themes = []
        self.emotionalToneRawValue = nil
        self.symbols = []
        self.lucidity = lucidity
        self.vividness = vividness
        self.isAnalyzed = false
    }

    // MARK: - Computed Properties

    var emotionalTone: EmotionalTone? {
        guard let rawValue = emotionalToneRawValue else { return nil }
        return EmotionalTone(rawValue: rawValue)
    }

    var displayTitle: String {
        title ?? "無題の夢"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E) HH:mm"
        return formatter.string(from: recordedAt)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: recordedAt)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: recordedAt)
    }

    var emotionalToneEmoji: String {
        emotionalTone?.emoji ?? "💭"
    }
}

// MARK: - DreamSymbolData（夢のシンボル永続化用）

struct DreamSymbolData: Codable, Sendable, Identifiable {
    var id: UUID
    let name: String
    let interpretation: String

    init(name: String, interpretation: String) {
        self.id = UUID()
        self.name = name
        self.interpretation = interpretation
    }
}
