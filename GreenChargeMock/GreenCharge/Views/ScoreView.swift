import SwiftUI

/// グリーンスコア・ゲーミフィケーションビュー
struct ScoreView: View {
    let viewModel: GreenChargeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // メインスコア
                    MainScoreCard(score: viewModel.greenScore)

                    // レベルプログレス
                    LevelProgressCard(score: viewModel.greenScore)

                    // 統計サマリー
                    StatsGrid(score: viewModel.greenScore)

                    // CO2 削減の可視化
                    CO2ImpactCard(score: viewModel.greenScore)
                }
                .padding()
            }
            .navigationTitle("グリーンスコア")
        }
    }
}

// MARK: - Main Score Card

private struct MainScoreCard: View {
    let score: GreenScore

    var body: some View {
        VStack(spacing: 16) {
            // レベルアイコン
            Image(systemName: score.level.systemImageName)
                .font(.system(size: 48))
                .foregroundStyle(.green.gradient)

            Text(score.level.rawValue)
                .font(.title2)
                .fontWeight(.bold)

            Text("\(score.totalPoints) pt")
                .font(.system(size: 36, weight: .bold, design: .rounded))

            // ランキング
            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.orange)
                Text(score.rankText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.green.opacity(0.08), .blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Level Progress

private struct LevelProgressCard: View {
    let score: GreenScore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("レベル進捗")
                    .font(.headline)
                Spacer()
                if let nextLevel = score.level.nextLevel {
                    Text("次: \(nextLevel.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let nextLevel = score.level.nextLevel {
                let progress = Double(score.totalPoints - score.level.pointsRequired)
                    / Double(nextLevel.pointsRequired - score.level.pointsRequired)

                ProgressView(value: min(1.0, progress))
                    .tint(.green)

                HStack {
                    Text("\(score.level.pointsRequired) pt")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(nextLevel.pointsRequired) pt")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("最高レベルに到達しました！")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Stats Grid

private struct StatsGrid: View {
    let score: GreenScore

    var body: some View {
        LazyVGrid(columns: [.init(), .init()], spacing: 12) {
            StatCard(
                icon: "bolt.fill",
                title: "クリーン充電率",
                value: score.cleanRateText,
                color: .green
            )
            StatCard(
                icon: "calendar",
                title: "今月のポイント",
                value: "\(score.monthlyPoints) pt",
                color: .blue
            )
            StatCard(
                icon: "globe.americas.fill",
                title: "CO2 削減量",
                value: score.co2Text,
                color: .teal
            )
            StatCard(
                icon: "person.3.fill",
                title: "コミュニティ",
                value: "\(score.totalParticipants)人",
                color: .purple
            )
        }
    }
}

private struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - CO2 Impact

private struct CO2ImpactCard: View {
    let score: GreenScore

    /// CO2 削減量を植樹換算
    var treesEquivalent: Int {
        Int(score.totalCO2Savings / 20)
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("あなたの環境貢献")
                .font(.headline)

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("🌳")
                        .font(.system(size: 36))
                    Text("植樹換算")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(treesEquivalent)本分")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                VStack(spacing: 4) {
                    Text("🚗")
                        .font(.system(size: 36))
                    Text("自動車走行")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(score.totalCO2Savings * 5)) km 分")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.green.opacity(0.06), .teal.opacity(0.06)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
