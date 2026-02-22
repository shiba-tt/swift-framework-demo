import SwiftUI

/// ダッシュボード画面 — 社会的つながりスコアの総合表示
struct DashboardView: View {
    let viewModel: SocialPulseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let score = viewModel.currentScore {
                        // メインスコアゲージ
                        ScoreGaugeCard(score: score)

                        // 評価テキスト
                        AssessmentCard(score: score)

                        // サブスコア一覧
                        SubScoreCards(score: score)

                        // トレンド表示
                        TrendCard(
                            trend: viewModel.weeklyTrend,
                            weeklyAverage: viewModel.weeklyAverageScore
                        )
                    } else {
                        ProgressView("データを読み込み中...")
                    }
                }
                .padding()
            }
            .navigationTitle("Social Pulse")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Score Gauge Card

private struct ScoreGaugeCard: View {
    let score: SocialScore

    var body: some View {
        VStack(spacing: 16) {
            Text("社会的つながりスコア")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack {
                // 背景リング
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 16)

                // スコアリング
                Circle()
                    .trim(from: 0, to: Double(score.overallScore) / 100.0)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(score.scoreLevel.colorName).opacity(0.6),
                                Color(score.scoreLevel.colorName),
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // 中心テキスト
                VStack(spacing: 4) {
                    Text("\(score.overallScore)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    Text("/ 100")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 200, height: 200)

            // スコアレベル表示
            HStack(spacing: 8) {
                Image(systemName: score.scoreLevel.systemImageName)
                    .foregroundStyle(Color(score.scoreLevel.colorName))
                Text(score.scoreLevel.rawValue)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(score.scoreLevel.colorName))

                if let change = score.changeFromPrevious {
                    HStack(spacing: 2) {
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(abs(change))")
                    }
                    .font(.caption)
                    .foregroundStyle(change >= 0 ? .green : .red)
                }
            }
            .font(.headline)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Assessment Card

private struct AssessmentCard: View {
    let score: SocialScore

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "text.bubble.fill")
                .font(.title2)
                .foregroundStyle(.pink)
                .frame(width: 44, height: 44)
                .background(.pink.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("今日の評価")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(score.assessmentText)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Sub Score Cards

private struct SubScoreCards: View {
    let score: SocialScore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ別スコア")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(SocialCategory.allCases) { category in
                    SubScoreCard(
                        category: category,
                        score: category.score(from: score)
                    )
                }
            }
        }
    }
}

private struct SubScoreCard: View {
    let category: SocialCategory
    let score: Int

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: Double(score) / 100.0)
                    .stroke(
                        Color(category.colorName),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(score)")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
            }
            .frame(width: 64, height: 64)

            Image(systemName: category.systemImageName)
                .font(.caption)
                .foregroundStyle(Color(category.colorName))
            Text(category.rawValue)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Trend Card

private struct TrendCard: View {
    let trend: WeeklyTrend
    let weeklyAverage: Int

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("週間トレンド")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: trend.systemImageName)
                        .foregroundStyle(Color(trend.colorName))
                    Text(trend.rawValue)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(trend.colorName))
                }
                .font(.headline)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("週間平均")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(weeklyAverage)")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
