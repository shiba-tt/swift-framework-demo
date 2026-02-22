import AppIntents
import Foundation

// MARK: - DeckCategoryAppEnum

enum DeckCategoryAppEnum: String, AppEnum {
    case english
    case japanese
    case science
    case history
    case programming
    case other

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "デッキカテゴリ")

    static var caseDisplayRepresentations: [DeckCategoryAppEnum: DisplayRepresentation] = [
        .english: "英語",
        .japanese: "国語",
        .science: "理科",
        .history: "歴史",
        .programming: "プログラミング",
        .other: "その他",
    ]
}

// MARK: - AnswerCardIntent

struct AnswerCardIntent: AppIntent {
    static var title: LocalizedStringResource = "フラッシュカードに回答"
    static var description = IntentDescription("表示中のカードに「知ってる」「知らない」で回答します")
    static var openAppWhenRun = false

    @Parameter(title: "正解")
    var isCorrect: Bool

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = StudyManager.shared
        guard let next = manager.quickStudyCard() else {
            return .result(dialog: "復習するカードがありません。素晴らしい！全カード学習済みです。")
        }

        manager.answerCard(next.card.id, in: next.deckId, isCorrect: isCorrect)
        let message = isCorrect ? "正解！" : "次はきっと覚えられます！"

        if let nextCard = manager.quickStudyCard() {
            return .result(dialog: "\(message)\n\n次のカード: \(nextCard.card.front)")
        } else {
            return .result(dialog: "\(message)\n\n今日の復習はすべて完了しました！")
        }
    }
}

// MARK: - QuickStudyIntent

struct QuickStudyIntent: AppIntent {
    static var title: LocalizedStringResource = "クイック学習"
    static var description = IntentDescription("復習が必要なカードを1枚出題します")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = StudyManager.shared
        guard let next = manager.quickStudyCard() else {
            return .result(dialog: "今日の復習は全て完了しています。お疲れ様でした！🎉")
        }
        return .result(dialog: "【問題】\n\(next.card.front)\n\n答えを思い浮かべてから「知ってる」か「知らない」で回答してください。")
    }
}

// MARK: - QueryStudyStatsIntent

struct QueryStudyStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "学習統計を確認"
    static var description = IntentDescription("今日の学習状況と全体の習得率を確認します")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = StudyManager.shared
        let stats = manager.dailyStats()
        let mastery = Int(manager.overallMastery * 100)

        let message = """
        📊 学習統計

        今日の学習: \(stats.cardsStudied)枚
        正答率: \(Int(stats.accuracy * 100))%
        連続学習: \(stats.streakDays)日

        全体の習得率: \(mastery)%
        残り復習カード: \(manager.totalDueCards)枚
        総カード数: \(manager.totalCards)枚
        """
        return .result(dialog: "\(message)")
    }
}

// MARK: - QueryDueCardsIntent

struct QueryDueCardsIntent: AppIntent {
    static var title: LocalizedStringResource = "残り復習カード数を確認"
    static var description = IntentDescription("今日復習が必要なカードの枚数を確認します")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = StudyManager.shared
        let dueCount = manager.totalDueCards

        if dueCount == 0 {
            return .result(dialog: "今日の復習は全て完了しています！素晴らしい継続力です。")
        } else {
            return .result(dialog: "復習が必要なカードが \(dueCount)枚 あります。さっそく始めましょう！")
        }
    }
}
