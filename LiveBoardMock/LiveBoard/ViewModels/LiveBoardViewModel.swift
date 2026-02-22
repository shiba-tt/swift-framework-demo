import Foundation
import SwiftUI

/// LiveBoard のメインビューモデル
@MainActor
@Observable
final class LiveBoardViewModel {
    // MARK: - State

    /// チームボード
    private(set) var board: TeamBoard = TeamBoard()

    /// チームメンバー
    private(set) var members: [TeamMember] = []

    /// タスク一覧
    private(set) var tasks: [BoardTask] = []

    /// 読み込み中フラグ
    private(set) var isLoading = false

    // MARK: - Dependencies

    let dataManager = LiveBoardDataManager.shared

    // MARK: - Computed Properties

    /// オンラインメンバー数
    var onlineMemberCount: Int {
        members.filter(\.isOnline).count
    }

    /// 完了タスク数
    var completedTaskCount: Int {
        tasks.filter(\.isCompleted).count
    }

    /// 未完了タスク数
    var pendingTaskCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    /// タスク完了率
    var completionPercentage: Int {
        guard !tasks.isEmpty else { return 0 }
        return Int(Double(completedTaskCount) / Double(tasks.count) * 100)
    }

    // MARK: - Actions

    /// 初期化
    func initialize() async {
        isLoading = true

        if let existingBoard = dataManager.loadBoard() {
            board = existingBoard
            members = existingBoard.members
            tasks = existingBoard.tasks
        } else {
            // 初回起動時にデモデータを生成
            generateDemoData()
        }

        isLoading = false
    }

    /// データの更新
    func refresh() {
        if let existingBoard = dataManager.loadBoard() {
            board = existingBoard
            members = existingBoard.members
            tasks = existingBoard.tasks
        }
    }

    /// メンバーのステータスを更新
    func updateStatus(memberId: UUID, status: String, emoji: String) {
        dataManager.updateMemberStatus(
            memberId: memberId,
            status: status,
            emoji: emoji,
            isOnline: true
        )
        refresh()
    }

    /// メンバーのオンライン状態を切り替え
    func toggleMemberOnline(memberId: UUID) {
        dataManager.toggleMemberOnline(memberId: memberId)
        refresh()
    }

    /// タスクの完了状態を切り替え
    func toggleTask(taskId: UUID) {
        dataManager.toggleTask(taskId: taskId)
        refresh()
    }

    /// タスクを追加
    func addTask(title: String, assignee: String? = nil) {
        dataManager.addTask(title: title, assignee: assignee)
        refresh()
    }

    /// タスクを削除
    func removeTask(taskId: UUID) {
        dataManager.removeTask(taskId: taskId)
        refresh()
    }

    /// メンバーを追加
    func addMember(name: String) {
        dataManager.addMember(name: name)
        refresh()
    }

    /// メンバーを削除
    func removeMember(memberId: UUID) {
        dataManager.removeMember(memberId: memberId)
        refresh()
    }

    /// ボード名を更新
    func updateBoardName(_ name: String) {
        dataManager.updateBoardName(name)
        refresh()
    }

    // MARK: - Demo Data

    private func generateDemoData() {
        let demoMembers: [TeamMember] = [
            TeamMember(
                name: "田中太郎",
                status: "デザインレビュー中",
                statusEmoji: "🎨",
                isOnline: true,
                lastUpdated: Date().addingTimeInterval(-300)
            ),
            TeamMember(
                name: "佐藤花子",
                status: "コーディング中",
                statusEmoji: "💻",
                isOnline: true,
                lastUpdated: Date().addingTimeInterval(-120)
            ),
            TeamMember(
                name: "鈴木一郎",
                status: "ミーティング中",
                statusEmoji: "📞",
                isOnline: true,
                lastUpdated: Date().addingTimeInterval(-600)
            ),
            TeamMember(
                name: "高橋美咲",
                status: "ランチ休憩",
                statusEmoji: "🍱",
                isOnline: false,
                lastUpdated: Date().addingTimeInterval(-1800)
            ),
            TeamMember(
                name: "渡辺健",
                status: "テスト実行中",
                statusEmoji: "🧪",
                isOnline: true,
                lastUpdated: Date().addingTimeInterval(-60)
            ),
        ]

        let calendar = Calendar.current
        let demoTasks: [BoardTask] = [
            BoardTask(
                title: "ログイン画面のUI改善",
                isCompleted: true,
                assignee: "田中太郎",
                createdAt: calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date()
            ),
            BoardTask(
                title: "APIエンドポイントの実装",
                isCompleted: true,
                assignee: "佐藤花子",
                createdAt: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date()
            ),
            BoardTask(
                title: "プッシュ通知の統合テスト",
                isCompleted: false,
                assignee: "渡辺健",
                createdAt: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            ),
            BoardTask(
                title: "パフォーマンス最適化",
                isCompleted: false,
                assignee: "鈴木一郎",
                createdAt: Date()
            ),
            BoardTask(
                title: "ユーザーガイドの作成",
                isCompleted: false,
                assignee: nil,
                createdAt: Date()
            ),
            BoardTask(
                title: "ダークモード対応",
                isCompleted: false,
                assignee: "高橋美咲",
                createdAt: calendar.date(byAdding: .hour, value: -5, to: Date()) ?? Date()
            ),
            BoardTask(
                title: "多言語対応（英語）",
                isCompleted: true,
                assignee: "佐藤花子",
                createdAt: calendar.date(byAdding: .day, value: -5, to: Date()) ?? Date()
            ),
        ]

        let demoBoard = TeamBoard(
            name: "Team Alpha",
            members: demoMembers,
            tasks: demoTasks,
            lastSyncedAt: Date()
        )

        dataManager.saveBoard(demoBoard)

        board = demoBoard
        members = demoMembers
        tasks = demoTasks
    }
}
