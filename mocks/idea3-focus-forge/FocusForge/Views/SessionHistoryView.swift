import SwiftUI
import SwiftData

/// ポモドーロセッション履歴画面
struct SessionHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PomodoroSession.startedAt, order: .reverse)
    private var allSessions: [PomodoroSession]

    var body: some View {
        NavigationStack {
            Group {
                if allSessions.isEmpty {
                    emptyState
                } else {
                    sessionList
                }
            }
            .navigationTitle("履歴")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "まだ記録がありません",
            systemImage: "clock.badge.questionmark",
            description: Text("ポモドーロを開始すると、ここに記録が表示されます")
        )
    }

    // MARK: - Session List

    private var sessionList: some View {
        List {
            // 今日のサマリー
            todaySummarySection

            // セッション一覧（日付ごとにグループ化）
            ForEach(groupedByDate, id: \.key) { date, sessions in
                Section {
                    ForEach(sessions, id: \.id) { session in
                        SessionRow(session: session)
                    }
                } header: {
                    Text(date, style: .date)
                }
            }
        }
    }

    // MARK: - Today Summary

    private var todaySummarySection: some View {
        Section("今日のサマリー") {
            HStack {
                StatCard(
                    title: "集中時間",
                    value: todayWorkMinutes,
                    unit: "分",
                    systemImage: "brain.head.profile",
                    color: .orange
                )
                StatCard(
                    title: "ポモドーロ",
                    value: todayCompletedWork,
                    unit: "回",
                    systemImage: "checkmark.circle.fill",
                    color: .green
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Computed

    private var todaySessions: [PomodoroSession] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        return allSessions.filter { $0.startedAt >= startOfDay }
    }

    private var todayCompletedWork: Int {
        todaySessions.filter { $0.phase == PomodoroPhase.work.rawValue && $0.isCompleted }.count
    }

    private var todayWorkMinutes: Int {
        let workSessions = todaySessions.filter { $0.phase == PomodoroPhase.work.rawValue && $0.isCompleted }
        let totalSeconds = workSessions.reduce(0) { $0 + $1.durationSeconds }
        return totalSeconds / 60
    }

    private var groupedByDate: [(key: Date, value: [PomodoroSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allSessions) { session in
            calendar.startOfDay(for: session.startedAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

// MARK: - Session Row

private struct SessionRow: View {
    let session: PomodoroSession

    var body: some View {
        HStack {
            Image(systemName: session.pomodoroPhase.systemImageName)
                .foregroundStyle(session.pomodoroPhase == .work ? .orange : .green)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.pomodoroPhase.label)
                    .font(.subheadline.bold())
                Text(session.startedAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.durationSeconds / 60)分")
                    .font(.subheadline)
                if session.isCompleted {
                    Text("完了")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else {
                    Text("中断")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: Int
    let unit: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(value)")
                .font(.title.bold())
                .contentTransition(.numericText())

            Text("\(title)(\(unit))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
    }
}
