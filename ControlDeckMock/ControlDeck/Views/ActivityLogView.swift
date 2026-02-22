import SwiftUI

// MARK: - ActivityLogView

struct ActivityLogView: View {
    @Bindable var viewModel: ControlDeckViewModel

    var body: some View {
        NavigationStack {
            List {
                if viewModel.logs.isEmpty {
                    emptyState
                } else {
                    // 今日のログ
                    let todayLogs = logsForToday
                    if !todayLogs.isEmpty {
                        Section("今日") {
                            ForEach(todayLogs) { log in
                                LogRowView(log: log)
                            }
                        }
                    }

                    // それ以前
                    let olderLogs = logsBeforeToday
                    if !olderLogs.isEmpty {
                        Section("それ以前") {
                            ForEach(olderLogs) { log in
                                LogRowView(log: log)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("アクティビティ")
        }
    }

    // MARK: - Computed

    private var logsForToday: [DeviceLog] {
        let calendar = Calendar.current
        return viewModel.logs.filter { calendar.isDateInToday($0.timestamp) }
    }

    private var logsBeforeToday: [DeviceLog] {
        let calendar = Calendar.current
        return viewModel.logs.filter { !calendar.isDateInToday($0.timestamp) }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("アクティビティはありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .listRowBackground(Color.clear)
    }
}

// MARK: - LogRowView

struct LogRowView: View {
    let log: DeviceLog

    var body: some View {
        HStack(spacing: 12) {
            Text(log.deviceEmoji)
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.deviceName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(log.action)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(log.formattedTime)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
