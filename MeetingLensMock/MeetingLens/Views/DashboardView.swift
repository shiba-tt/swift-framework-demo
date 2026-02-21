import SwiftUI

/// ダッシュボード画面：会議コスト概要
struct DashboardView: View {
    let viewModel: MeetingLensViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 今日のコストカード
                    todayCostCard

                    // 統計カード群
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12) {
                        statCard(
                            title: "今日の会議",
                            value: "\(viewModel.todayStats.totalMeetings)件",
                            icon: "calendar",
                            color: .blue
                        )
                        statCard(
                            title: "今日の会議時間",
                            value: viewModel.todayStats.totalTimeText,
                            icon: "clock.fill",
                            color: .purple
                        )
                        statCard(
                            title: "平均参加者",
                            value: String(format: "%.1f人", viewModel.todayStats.averageAttendees),
                            icon: "person.2.fill",
                            color: .green
                        )
                        statCard(
                            title: "ディープワーク",
                            value: viewModel.todayStats.deepWorkScoreText,
                            icon: "brain.head.profile.fill",
                            color: .indigo,
                            suffix: "pt"
                        )
                    }

                    // 今週のサマリー
                    weekSummaryCard

                    // 繰り返し会議率
                    recurringCard
                }
                .padding()
            }
            .navigationTitle("MeetingLens")
            .refreshable {
                await viewModel.loadAllData()
            }
        }
    }

    // MARK: - Subviews

    private var todayCostCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "yensign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("今日の会議コスト")
                    .font(.headline)
                Spacer()
            }

            Text(viewModel.todayCostText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)

            HStack(spacing: 16) {
                Label(
                    "\(viewModel.todayStats.totalMeetings)件",
                    systemImage: "calendar"
                )
                Label(
                    viewModel.todayStats.totalTimeText,
                    systemImage: "clock"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weekSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("今週のサマリー")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text(viewModel.weekCostText)
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                    Text("総コスト")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider().frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(viewModel.weekStats.totalMeetings)件")
                        .font(.title2.bold())
                    Text("会議数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider().frame(height: 40)

                VStack(spacing: 4) {
                    Text(viewModel.weekStats.totalTimeText)
                        .font(.title2.bold())
                    Text("会議時間")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var recurringCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.purple)
                Text("繰り返し会議の割合")
                    .font(.headline)
                Spacer()
            }

            HStack {
                let rate = viewModel.weekStats.recurringRate
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: rate)
                        .stroke(.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(rate * 100))%")
                        .font(.title3.bold())
                }
                .frame(width: 80, height: 80)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let mostExpensive = viewModel.weekStats.mostExpensiveMeeting {
                        Text("最高コスト会議")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(mostExpensive)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                    }
                    Text("平均\(viewModel.weekStats.averageDurationMinutes)分/件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.purple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        suffix: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3.bold())
                if let suffix {
                    Text(suffix)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
