import SwiftUI

struct TimelineView: View {
    let viewModel: TenKiLogViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    todaySection()
                    oneYearAgoSection()
                    recentLogsList()
                }
                .padding()
            }
            .navigationTitle("TenKi Log")
        }
    }

    // MARK: - Today

    @ViewBuilder
    private func todaySection() -> some View {
        if let today = viewModel.todayLog() {
            VStack(spacing: 12) {
                HStack {
                    Text("今日の天気")
                        .font(.headline)
                    Spacer()
                    Text(today.dateFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(today.condition.emoji)
                            .font(.system(size: 48))
                        Text(today.condition.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "thermometer.medium")
                                .foregroundStyle(.orange)
                            Text(today.temperatureRange)
                                .font(.subheadline)
                        }
                        HStack {
                            Image(systemName: "humidity.fill")
                                .foregroundStyle(.cyan)
                            Text("\(Int(today.humidity * 100))%")
                                .font(.subheadline)
                        }
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.33percent")
                                .foregroundStyle(.purple)
                            Text(today.pressureFormatted)
                                .font(.subheadline)
                        }
                    }

                    Spacer()

                    if let mood = today.mood {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.system(size: 36))
                            Text(mood.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let comparison = today.historicalComparison {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text(comparison)
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                if let note = today.diaryNote {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundStyle(.secondary)
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - One Year Ago

    @ViewBuilder
    private func oneYearAgoSection() -> some View {
        if let yearAgo = viewModel.oneYearAgoLog() {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.indigo)
                    Text("1\u{5E74}\u{524D}\u{306E}\u{4ECA}\u{65E5}")
                        .font(.headline)
                    Spacer()
                    Text(yearAgo.dateFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Text(yearAgo.condition.emoji)
                        .font(.title)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(yearAgo.condition.displayName)
                            .font(.subheadline)
                        Text(yearAgo.temperatureRange)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let mood = yearAgo.mood {
                        Text(mood.emoji)
                            .font(.title2)
                    }
                }

                if let note = yearAgo.diaryNote {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Recent Logs

    private func recentLogsList() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近の記録")
                .font(.headline)

            ForEach(viewModel.recentLogs(count: 14).reversed()) { log in
                logRow(log)
            }
        }
    }

    private func logRow(_ log: WeatherLog) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(log.monthDay)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(log.dayOfWeek)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)

            Text(log.condition.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(log.condition.displayName)
                        .font(.subheadline)
                    if let comparison = log.historicalComparison {
                        Text(comparison)
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(.orange.opacity(0.1), in: Capsule())
                    }
                }
                Text(log.temperatureRange)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let mood = log.mood {
                Text(mood.emoji)
                    .font(.title3)
            }

            if !log.healthConditions.contains(.none) && !log.healthConditions.isEmpty {
                HStack(spacing: 2) {
                    ForEach(log.healthConditions.filter { $0 != .none }) { condition in
                        Text(condition.emoji)
                            .font(.caption)
                    }
                }
            }

            if log.photoCount > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "photo")
                        .font(.system(size: 10))
                    Text("\(log.photoCount)")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }
}
