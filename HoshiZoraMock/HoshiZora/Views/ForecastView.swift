import SwiftUI

struct ForecastView: View {
    @Bindable var viewModel: HoshiZoraViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("星空予報を作成中...")
                } else if viewModel.weeklyForecast.isEmpty {
                    ContentUnavailableView("予報データなし", systemImage: "calendar.badge.exclamationmark")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            bestNightBanner()
                            forecastListSection()
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("10日間 星空予報")
        }
    }

    // MARK: - Best Night Banner

    private func bestNightBanner() -> some View {
        Group {
            if let best = viewModel.bestNightThisWeek {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                        Text("今週のベスト観測日")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Spacer()
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(best.formattedDate)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text(best.moonPhase.emoji + " " + best.moonPhase.displayName)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Spacer()
                        VStack {
                            Text("\(best.overallScore)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.yellow)
                            Text(best.scoreLevel.displayName)
                                .font(.caption)
                                .foregroundStyle(.yellow.opacity(0.8))
                        }
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.0, blue: 0.25), Color(red: 0.15, green: 0.05, blue: 0.35)],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
        }
    }

    // MARK: - Forecast List

    private func forecastListSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別予報")
                .font(.headline)

            ForEach(viewModel.weeklyForecast) { condition in
                forecastRow(condition)
            }
        }
    }

    private func forecastRow(_ condition: StargazingCondition) -> some View {
        HStack(spacing: 12) {
            // 日付
            VStack(alignment: .leading, spacing: 2) {
                Text(condition.formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(condition.moonPhase.emoji + " " + condition.moonPhase.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 85, alignment: .leading)

            // スコアバー
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.fill.secondary)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(condition.scoreLevel.color)
                        .frame(width: geo.size.width * CGFloat(condition.overallScore) / 100.0)
                }
            }
            .frame(height: 20)

            // スコア
            Text("\(condition.overallScore)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(condition.scoreLevel.color)
                .frame(width: 30, alignment: .trailing)

            // 星表示
            starsCompact(condition.scoreLevel.stars)
        }
        .padding(12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func starsCompact(_ count: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<5) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .font(.system(size: 8))
                    .foregroundStyle(i < count ? .yellow : .gray.opacity(0.3))
            }
        }
        .frame(width: 48)
    }
}
