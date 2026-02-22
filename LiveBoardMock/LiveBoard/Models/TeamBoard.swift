import Foundation

/// チームボード全体のモデル
struct TeamBoard: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var members: [TeamMember]
    var tasks: [BoardTask]
    var lastSyncedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "Team Alpha",
        members: [TeamMember] = [],
        tasks: [BoardTask] = [],
        lastSyncedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.tasks = tasks
        self.lastSyncedAt = lastSyncedAt
    }

    /// オンラインメンバー数
    var onlineMemberCount: Int {
        members.filter(\.isOnline).count
    }

    /// 全メンバー数
    var totalMemberCount: Int {
        members.count
    }

    /// 完了タスク数
    var completedTaskCount: Int {
        tasks.filter(\.isCompleted).count
    }

    /// 未完了タスク数
    var pendingTaskCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    /// 全タスク数
    var totalTaskCount: Int {
        tasks.count
    }

    /// タスク完了率（パーセント）
    var completionPercentage: Int {
        guard !tasks.isEmpty else { return 0 }
        return Int(Double(completedTaskCount) / Double(totalTaskCount) * 100)
    }

    /// 最終同期の表示テキスト
    var lastSyncedText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: lastSyncedAt)
    }

    /// オンライン状況のサマリーテキスト
    var onlineSummaryText: String {
        "\(name) - \(onlineMemberCount)人オンライン"
    }

    /// タスクサマリーテキスト
    var taskSummaryText: String {
        "\(completedTaskCount)/\(totalTaskCount) タスク完了"
    }
}
