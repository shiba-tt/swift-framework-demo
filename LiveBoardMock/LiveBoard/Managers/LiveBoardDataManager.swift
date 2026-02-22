import Foundation
import WidgetKit

/// LiveBoard のデータ管理マネージャー
/// App Group 経由で Widget と状態を共有する
@MainActor
@Observable
final class LiveBoardDataManager {

    // MARK: - Singleton

    static let shared = LiveBoardDataManager()
    private init() {}

    // MARK: - Constants

    private let appGroupID = "group.com.example.liveboard"
    private let boardKey = "teamBoard"
    private let membersKey = "teamMembers"
    private let tasksKey = "boardTasks"
    private let boardNameKey = "boardName"
    private let lastSyncKey = "lastSyncedAt"

    // MARK: - Data Access

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Board Management

    /// ボードデータを保存する
    func saveBoard(_ board: TeamBoard) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(board) else { return }
        sharedDefaults?.set(data, forKey: boardKey)
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: lastSyncKey)

        // ウィジェットの更新を通知
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// ボードデータを読み込む
    func loadBoard() -> TeamBoard? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: boardKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(TeamBoard.self, from: data)
    }

    // MARK: - Member Management

    /// メンバーのステータスを更新する
    func updateMemberStatus(memberId: UUID, status: String, emoji: String, isOnline: Bool) {
        guard var board = loadBoard() else { return }

        if let index = board.members.firstIndex(where: { $0.id == memberId }) {
            board.members[index].status = status
            board.members[index].statusEmoji = emoji
            board.members[index].isOnline = isOnline
            board.members[index].lastUpdated = Date()
        }

        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    /// メンバーのオンライン状態を切り替える
    func toggleMemberOnline(memberId: UUID) {
        guard var board = loadBoard() else { return }

        if let index = board.members.firstIndex(where: { $0.id == memberId }) {
            board.members[index].isOnline.toggle()
            board.members[index].lastUpdated = Date()
        }

        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    /// メンバーを追加する
    func addMember(name: String) {
        guard var board = loadBoard() else { return }

        let member = TeamMember(name: name)
        board.members.append(member)
        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    /// メンバーを削除する
    func removeMember(memberId: UUID) {
        guard var board = loadBoard() else { return }

        board.members.removeAll { $0.id == memberId }
        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    // MARK: - Task Management

    /// タスクの完了状態を切り替える
    func toggleTask(taskId: UUID) {
        guard var board = loadBoard() else { return }

        if let index = board.tasks.firstIndex(where: { $0.id == taskId }) {
            board.tasks[index].isCompleted.toggle()
        }

        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    /// タスクを追加する
    func addTask(title: String, assignee: String? = nil) {
        guard var board = loadBoard() else { return }

        let task = BoardTask(title: title, assignee: assignee)
        board.tasks.append(task)
        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    /// タスクを削除する
    func removeTask(taskId: UUID) {
        guard var board = loadBoard() else { return }

        board.tasks.removeAll { $0.id == taskId }
        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    // MARK: - Board Settings

    /// ボード名を更新する
    func updateBoardName(_ name: String) {
        guard var board = loadBoard() else { return }

        board.name = name
        board.lastSyncedAt = Date()
        saveBoard(board)
    }

    // MARK: - Widget Data (Quick Access)

    /// ウィジェット用：オンラインメンバー数を取得
    func loadOnlineMemberCount() -> Int {
        loadBoard()?.onlineMemberCount ?? 0
    }

    /// ウィジェット用：メンバーリストを取得
    func loadMembers() -> [TeamMember] {
        loadBoard()?.members ?? []
    }

    /// ウィジェット用：タスクリストを取得
    func loadTasks() -> [BoardTask] {
        loadBoard()?.tasks ?? []
    }

    /// ウィジェット用：ボード名を取得
    func loadBoardName() -> String {
        loadBoard()?.name ?? "Team Alpha"
    }

    /// ウィジェット用：最終同期時刻
    func loadLastSyncTime() -> String {
        guard let interval = sharedDefaults?.double(forKey: lastSyncKey), interval > 0 else {
            return "--:--"
        }
        let date = Date(timeIntervalSince1970: interval)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
