import Foundation

/// チームメンバーの情報モデル
struct TeamMember: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var status: String
    var statusEmoji: String
    var isOnline: Bool
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String,
        status: String = "作業中",
        statusEmoji: String = "💻",
        isOnline: Bool = true,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.statusEmoji = statusEmoji
        self.isOnline = isOnline
        self.lastUpdated = lastUpdated
    }

    /// 最終更新からの経過時間テキスト
    var lastUpdatedText: String {
        let interval = Date().timeIntervalSince(lastUpdated)
        let minutes = Int(interval / 60)
        if minutes < 1 {
            return "たった今"
        } else if minutes < 60 {
            return "\(minutes)分前"
        } else {
            let hours = minutes / 60
            if hours < 24 {
                return "\(hours)時間前"
            } else {
                let days = hours / 24
                return "\(days)日前"
            }
        }
    }

    /// ステータス表示テキスト（絵文字付き）
    var displayStatus: String {
        "\(statusEmoji) \(status)"
    }

    /// オンラインステータスの色名
    var onlineColorName: String {
        isOnline ? "green" : "gray"
    }
}
