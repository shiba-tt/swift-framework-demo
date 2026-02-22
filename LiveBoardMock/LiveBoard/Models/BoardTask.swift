import Foundation

/// ボードのタスクモデル
struct BoardTask: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var assignee: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        assignee: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.assignee = assignee
        self.createdAt = createdAt
    }

    /// 作成日の表示テキスト
    var createdAtText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: createdAt)
    }

    /// 短い日付テキスト
    var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: createdAt)
    }

    /// 担当者の表示テキスト
    var assigneeText: String {
        if let assignee {
            return assignee
        }
        return "未割り当て"
    }
}
