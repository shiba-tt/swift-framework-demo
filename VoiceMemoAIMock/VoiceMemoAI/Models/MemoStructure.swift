import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - MemoStructure（Foundation Models 構造化出力）

/// @Generable マクロにより Foundation Models が型安全な構造化出力を生成する。
/// ビルド環境に FoundationModels が無い場合でもコンパイルできるよう条件付きで定義。

#if canImport(FoundationModels)

@Generable
struct MemoStructure {
    @Guide(description: "メモの簡潔なタイトル（20文字以内）")
    var title: String

    @Guide(description: "メモのカテゴリ", .enum(MemoType.self))
    var category: MemoType

    @Guide(description: "メモから抽出した重要なポイント（最大5つ）")
    var keyPoints: [String]

    @Guide(description: "メモから抽出したアクションアイテム")
    var actionItems: [ActionItem]

    @Guide(description: "メモの内容を整理した要約（100文字以内）")
    var summary: String
}

@Generable
enum MemoType: String {
    case meeting, shopping, todo, idea, diary, other
}

@Generable
struct ActionItem {
    @Guide(description: "アクションの内容")
    var content: String

    @Guide(description: "担当者の名前（不明な場合は空文字）")
    var assignee: String

    @Guide(description: "優先度", .enum(Priority.self))
    var priority: Priority
}

@Generable
enum Priority: String {
    case high, medium, low
}

#else

// MARK: - Fallback（FoundationModels が利用できない環境向け）

struct MemoStructure: Sendable {
    var title: String
    var category: MemoType
    var keyPoints: [String]
    var actionItems: [ActionItem]
    var summary: String
}

enum MemoType: String, Sendable {
    case meeting, shopping, todo, idea, diary, other
}

struct ActionItem: Sendable {
    var content: String
    var assignee: String
    var priority: Priority
}

enum Priority: String, Sendable {
    case high, medium, low
}

#endif

// MARK: - MemoStatistics

struct MemoStatistics: Sendable {
    let totalCount: Int
    let categoryCounts: [MemoCategory: Int]
    let pendingActionItems: Int
    let completedActionItems: Int
    let averageDuration: TimeInterval
    let thisWeekCount: Int

    var completionRate: Double {
        let total = pendingActionItems + completedActionItems
        guard total > 0 else { return 0 }
        return Double(completedActionItems) / Double(total)
    }

    var formattedAverageDuration: String {
        let minutes = Int(averageDuration) / 60
        let seconds = Int(averageDuration) % 60
        if minutes > 0 {
            return "\(minutes)分\(seconds)秒"
        }
        return "\(seconds)秒"
    }

    static let empty = MemoStatistics(
        totalCount: 0,
        categoryCounts: [:],
        pendingActionItems: 0,
        completedActionItems: 0,
        averageDuration: 0,
        thisWeekCount: 0
    )
}
