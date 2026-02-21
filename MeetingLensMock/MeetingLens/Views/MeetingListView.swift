import SwiftUI

/// 会議一覧画面
struct MeetingListView: View {
    let viewModel: MeetingLensViewModel

    @State private var selectedScope: Scope = .today

    enum Scope: String, CaseIterable {
        case today = "今日"
        case week = "今週"
        case month = "今月"
    }

    private var meetings: [MeetingEvent] {
        switch selectedScope {
        case .today: viewModel.todayMeetings
        case .week: viewModel.weekMeetings
        case .month: viewModel.monthMeetings
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // スコープ切り替え
                Picker("期間", selection: $selectedScope) {
                    ForEach(Scope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // 会議リスト
                List {
                    // サマリーセクション
                    Section {
                        HStack(spacing: 16) {
                            summaryItem(
                                value: "\(meetings.count)",
                                label: "件",
                                color: .blue
                            )
                            Divider()
                            summaryItem(
                                value: totalTimeText,
                                label: "合計時間",
                                color: .purple
                            )
                            Divider()
                            summaryItem(
                                value: totalCostText,
                                label: "総コスト",
                                color: .orange
                            )
                        }
                        .padding(.vertical, 4)
                    }

                    // 会議一覧
                    Section("会議一覧") {
                        ForEach(meetings) { meeting in
                            meetingRow(meeting)
                        }
                    }
                }
            }
            .navigationTitle("会議一覧")
        }
    }

    // MARK: - Subviews

    private func meetingRow(_ meeting: MeetingEvent) -> some View {
        HStack(spacing: 12) {
            // カラーインジケーター
            RoundedRectangle(cornerRadius: 3)
                .fill(meeting.calendarColor)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(meeting.timeText, systemImage: "clock")
                    Label("\(meeting.attendeeCount)人", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(costText(for: meeting))
                    .font(.subheadline.bold())
                    .foregroundStyle(.orange)

                Text(meeting.durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if meeting.isRecurring {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2)
                        .foregroundStyle(.purple)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func summaryItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func costText(for meeting: MeetingEvent) -> String {
        let cost = meeting.estimatedCost(hourlyRate: viewModel.hourlyRate)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: cost)) ?? "¥0"
    }

    private var totalTimeText: String {
        let total = meetings.reduce(0) { $0 + $1.durationMinutes }
        let hours = total / 60
        let minutes = total % 60
        if hours > 0 {
            return "\(hours)h\(minutes)m"
        }
        return "\(minutes)m"
    }

    private var totalCostText: String {
        let total = meetings.reduce(0.0) { $0 + $1.estimatedCost(hourlyRate: viewModel.hourlyRate) }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: total)) ?? "¥0"
    }
}
