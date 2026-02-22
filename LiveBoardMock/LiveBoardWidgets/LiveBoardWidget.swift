import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct LiveBoardWidgetEntry: TimelineEntry {
    let date: Date
    let boardName: String
    let onlineCount: Int
    let totalMembers: Int
    let completedTasks: Int
    let totalTasks: Int
    let members: [(name: String, emoji: String, status: String, isOnline: Bool)]
    let tasks: [(id: String, title: String, isCompleted: Bool, assignee: String?)]
    let lastSyncTime: String
}

// MARK: - Timeline Provider

struct LiveBoardWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.example.liveboard"

    func placeholder(in context: Context) -> LiveBoardWidgetEntry {
        LiveBoardWidgetEntry(
            date: .now,
            boardName: "Team Alpha",
            onlineCount: 3,
            totalMembers: 5,
            completedTasks: 4,
            totalTasks: 7,
            members: [
                ("田中太郎", "🎨", "デザインレビュー中", true),
                ("佐藤花子", "💻", "コーディング中", true),
                ("鈴木一郎", "📞", "ミーティング中", true),
                ("高橋美咲", "🍱", "ランチ休憩", false),
                ("渡辺健", "🧪", "テスト実行中", true),
            ],
            tasks: [
                ("1", "ログイン画面のUI改善", true, "田中太郎"),
                ("2", "APIエンドポイントの実装", true, "佐藤花子"),
                ("3", "プッシュ通知の統合テスト", false, "渡辺健"),
                ("4", "パフォーマンス最適化", false, "鈴木一郎"),
            ],
            lastSyncTime: "14:30"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LiveBoardWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LiveBoardWidgetEntry>) -> Void) {
        let entry = loadEntry()

        // 15分後に再更新（プッシュ更新も併用）
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> LiveBoardWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)

        guard let data = defaults?.data(forKey: "teamBoard"),
              let board = try? JSONDecoder().decode(TeamBoard.self, from: data) else {
            return placeholder(in: .init())
        }

        let members = board.members.map { member in
            (name: member.name, emoji: member.statusEmoji, status: member.status, isOnline: member.isOnline)
        }

        let tasks = board.tasks.map { task in
            (id: task.id.uuidString, title: task.title, isCompleted: task.isCompleted, assignee: task.assignee)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let syncTime = formatter.string(from: board.lastSyncedAt)

        return LiveBoardWidgetEntry(
            date: .now,
            boardName: board.name,
            onlineCount: board.onlineMemberCount,
            totalMembers: board.totalMemberCount,
            completedTasks: board.completedTaskCount,
            totalTasks: board.totalTaskCount,
            members: members,
            tasks: tasks,
            lastSyncTime: syncTime
        )
    }
}

// MARK: - AppIntents（タスク完了切替）

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "タスク完了切替"

    @Parameter(title: "タスクID")
    var taskId: String

    init() {}

    init(taskId: String) {
        self.taskId = taskId
    }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.liveboard")

        guard let data = defaults?.data(forKey: "teamBoard"),
              var board = try? JSONDecoder().decode(TeamBoard.self, from: data),
              let uuid = UUID(uuidString: taskId),
              let index = board.tasks.firstIndex(where: { $0.id == uuid }) else {
            return .result()
        }

        board.tasks[index].isCompleted.toggle()
        board.lastSyncedAt = Date()

        if let encodedData = try? JSONEncoder().encode(board) {
            defaults?.set(encodedData, forKey: "teamBoard")
        }

        return .result()
    }
}

// MARK: - Widget Views

struct LiveBoardWidgetView: View {
    var entry: LiveBoardWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        case .accessoryCircular:
            circularWidget
        case .accessoryRectangular:
            rectangularWidget
        case .accessoryInline:
            inlineWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget（チーム活動サマリー）

    private var smallWidget: some View {
        VStack(spacing: 8) {
            HStack {
                Text("📋")
                    .font(.title3)
                Text(entry.boardName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
            }

            Divider()

            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                    Text("\(entry.onlineCount)/\(entry.totalMembers)人")
                        .font(.caption2)
                    Spacer()
                }

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.blue)
                    Text("\(entry.completedTasks)/\(entry.totalTasks) タスク")
                        .font(.caption2)
                    Spacer()
                }
            }

            Spacer()

            HStack {
                Spacer()
                Text("同期 \(entry.lastSyncTime)")
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget（メンバー + タスク概要）

    private var mediumWidget: some View {
        HStack(spacing: 12) {
            // メンバーステータス
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("📋")
                        .font(.caption)
                    Text(entry.boardName)
                        .font(.caption)
                        .fontWeight(.bold)
                }

                ForEach(Array(entry.members.prefix(4).enumerated()), id: \.offset) { _, member in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(member.isOnline ? .green : .gray)
                            .frame(width: 6, height: 6)
                        Text(member.emoji)
                            .font(.system(size: 10))
                        Text(member.name)
                            .font(.system(size: 10))
                            .lineLimit(1)
                    }
                }

                if entry.totalMembers > 4 {
                    Text("他 \(entry.totalMembers - 4)人")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // タスクサマリー
            VStack(alignment: .leading, spacing: 4) {
                Text("タスク進捗")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                let percentage = entry.totalTasks > 0
                    ? Int(Double(entry.completedTasks) / Double(entry.totalTasks) * 100)
                    : 0

                Text("\(percentage)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)

                ProgressView(value: Double(entry.completedTasks), total: Double(max(entry.totalTasks, 1)))
                    .tint(.blue)

                Text("\(entry.completedTasks)/\(entry.totalTasks) 完了")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("同期 \(entry.lastSyncTime)")
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }
            .frame(width: 90)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Large Widget（フルダッシュボード）

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ヘッダー
            HStack {
                Text("📋")
                    .font(.title3)
                Text(entry.boardName)
                    .font(.headline)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("\(entry.onlineCount)人オンライン")
                        .font(.caption2)
                }
            }

            Divider()

            // メンバーステータス
            Text("メンバー")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            ForEach(Array(entry.members.prefix(5).enumerated()), id: \.offset) { _, member in
                HStack(spacing: 6) {
                    Circle()
                        .fill(member.isOnline ? .green : .gray)
                        .frame(width: 8, height: 8)
                    Text(member.emoji)
                        .font(.caption)
                    Text(member.name)
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text(member.status)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Divider()

            // タスクリスト（インタラクティブ）
            Text("タスク（\(entry.completedTasks)/\(entry.totalTasks)）")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            ForEach(Array(entry.tasks.prefix(4).enumerated()), id: \.offset) { _, task in
                Button(intent: ToggleTaskIntent(taskId: task.id)) {
                    HStack(spacing: 6) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                            .foregroundStyle(task.isCompleted ? .green : .secondary)
                        Text(task.title)
                            .font(.caption)
                            .strikethrough(task.isCompleted)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            .lineLimit(1)
                        Spacer()
                        if let assignee = task.assignee {
                            Text(assignee)
                                .font(.system(size: 9))
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // フッター
            HStack {
                Spacer()
                Text("最終同期 \(entry.lastSyncTime)")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Widgets

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Text("\(entry.onlineCount)")
                    .font(.system(size: 18, weight: .bold))
                Text("人")
                    .font(.system(size: 9))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("📋")
                    .font(.system(size: 10))
                Text(entry.boardName)
                    .font(.caption)
                    .fontWeight(.bold)
            }

            ForEach(Array(entry.tasks.filter { !$0.isCompleted }.prefix(2).enumerated()), id: \.offset) { _, task in
                HStack(spacing: 3) {
                    Image(systemName: "circle")
                        .font(.system(size: 8))
                    Text(task.title)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }

            Text("\(entry.completedTasks)/\(entry.totalTasks) 完了")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var inlineWidget: some View {
        Text("\(entry.boardName) - \(entry.onlineCount)人オンライン")
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct LiveBoardWidget: Widget {
    let kind: String = "LiveBoardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LiveBoardWidgetProvider()) { entry in
            LiveBoardWidgetView(entry: entry)
        }
        .configurationDisplayName("LiveBoard")
        .description("チームのリアルタイムダッシュボード。メンバーのステータスとタスク進捗を確認できます")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
