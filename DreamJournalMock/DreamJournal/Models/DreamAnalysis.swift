import Foundation
import FoundationModels

// MARK: - DreamAnalysis（Foundation Models による構造化出力）

@Generable
struct DreamAnalysis {
    @Guide(description: "A short, symbolic title for the dream in Japanese (10 characters or less)")
    var title: String

    @Guide(description: "Main themes of the dream in Japanese (2-4 themes)")
    var themes: [String]

    @Guide(description: "The overall emotional tone of the dream")
    var emotionalTone: EmotionalTone

    @Guide(description: "Symbols that appeared in the dream with their common interpretations in Japanese (1-4 symbols)")
    var symbols: [DreamSymbol]

    @Guide(description: "A structured narrative retelling of the dream in Japanese (100 characters or less)")
    var narrative: String
}

// MARK: - EmotionalTone（感情トーン）

@Generable
enum EmotionalTone: String, Sendable, CaseIterable {
    case joyful = "joyful"
    case anxious = "anxious"
    case peaceful = "peaceful"
    case confused = "confused"
    case adventurous = "adventurous"
    case melancholic = "melancholic"
    case fearful = "fearful"
    case nostalgic = "nostalgic"

    var displayName: String {
        switch self {
        case .joyful: "喜び"
        case .anxious: "不安"
        case .peaceful: "穏やか"
        case .confused: "困惑"
        case .adventurous: "冒険的"
        case .melancholic: "憂鬱"
        case .fearful: "恐怖"
        case .nostalgic: "懐かしさ"
        }
    }

    var emoji: String {
        switch self {
        case .joyful: "😊"
        case .anxious: "😰"
        case .peaceful: "😌"
        case .confused: "😵‍💫"
        case .adventurous: "🗺️"
        case .melancholic: "😢"
        case .fearful: "😨"
        case .nostalgic: "🥹"
        }
    }

    var colorName: String {
        switch self {
        case .joyful: "yellow"
        case .anxious: "orange"
        case .peaceful: "mint"
        case .confused: "purple"
        case .adventurous: "blue"
        case .melancholic: "gray"
        case .fearful: "red"
        case .nostalgic: "pink"
        }
    }
}

// MARK: - DreamSymbol（夢のシンボル）

@Generable
struct DreamSymbol: Sendable {
    @Guide(description: "The name of the symbol in Japanese")
    var name: String

    @Guide(description: "Common interpretation of this symbol in dreams, in Japanese (30 characters or less)")
    var interpretation: String
}
