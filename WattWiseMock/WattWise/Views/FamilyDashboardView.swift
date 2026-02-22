import SwiftUI

/// ファミリーダッシュボード — チャレンジ・メンバー・インサイト表示
struct FamilyDashboardView: View {
    @Bindable var viewModel: WattWiseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    challengeCard
                    familyMembersCard
                    dailyInsightCard
                    gridPreviewCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("🏠 \(viewModel.familyName)")
        }
    }

    // MARK: - チャレンジカード

    private var challengeCard: some View {
        Group {
            if let challenge = viewModel.currentChallenge {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: challenge.icon)
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text("今週のチャレンジ")
                            .font(.headline)
                    }

                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(.green)
                        Text(challenge.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("進捗")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(challenge.progressPercent)%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green.opacity(0.2))

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green)
                                    .frame(width: geometry.size.width * challenge.currentProgress)
                            }
                        }
                        .frame(height: 12)
                    }

                    Text("残り \(challenge.remainingDays) 日!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - 家族メンバーカード

    private var familyMembersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("家族メンバー", systemImage: "person.3.fill")
                .font(.headline)

            ForEach(viewModel.familyMembers) { member in
                memberRow(member)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func memberRow(_ member: FamilyMember) -> some View {
        HStack(spacing: 12) {
            Text(member.icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if member.role == .parent {
                    HStack(spacing: 4) {
                        Text(member.deviceType.emoji)
                        Text(member.deviceType.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack(spacing: 4) {
                        Text(member.deviceType.emoji)
                        Text("Quiz 正解 \(member.quizScore) pt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if member.role == .parent {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("クリーン率")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text(member.displayCleanRate)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(member.cleanEnergyRate > 0.7 ? .green : .orange)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - 今日のインサイト

    private var dailyInsightCard: some View {
        Group {
            if let insight = viewModel.dailyInsight {
                VStack(alignment: .leading, spacing: 12) {
                    Label("今日のインサイト", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)

                    HStack(spacing: 16) {
                        insightBadge(
                            emoji: "🌍",
                            value: String(format: "%.1f kg", insight.co2Reduction),
                            label: "CO2 削減"
                        )
                        insightBadge(
                            emoji: "💰",
                            value: String(format: "$%.2f", insight.costSaving),
                            label: "コスト削減"
                        )
                        insightBadge(
                            emoji: "🌱",
                            value: "\(Int(insight.cleanRate * 100))%",
                            label: "クリーン率"
                        )
                        insightBadge(
                            emoji: "📈",
                            value: "\(insight.comparedToLastWeek >= 0 ? "+" : "")\(Int(insight.comparedToLastWeek * 100))%",
                            label: "先週比"
                        )
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func insightBadge(emoji: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title3)
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - グリッドプレビュー

    private var gridPreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("今日のグリッド状況", systemImage: "bolt.fill")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(viewModel.gridTimeSlots) { slot in
                        VStack(spacing: 4) {
                            Text(slot.cleanLevel.emoji)
                                .font(.system(size: 10))

                            RoundedRectangle(cornerRadius: 3)
                                .fill(slot.cleanLevel.color)
                                .frame(width: 14, height: 30)

                            Text("\(slot.hour)")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                legendItem(color: .green, label: "クリーン")
                legendItem(color: .yellow, label: "普通")
                legendItem(color: .red, label: "ピーク")
            }
            .font(.caption2)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}
