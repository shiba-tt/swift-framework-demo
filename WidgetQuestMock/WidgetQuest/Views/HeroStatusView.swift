import SwiftUI

/// 勇者のステータス詳細画面
struct HeroStatusView: View {
    @Bindable var viewModel: WidgetQuestViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroProfileCard
                    statusDetailCard
                    experienceCard
                    statsGridCard
                }
                .padding()
            }
            .navigationTitle("勇者")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Hero Profile

    private var heroProfileCard: some View {
        VStack(spacing: 16) {
            // アイコンとレベル
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.indigo.opacity(0.3), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Text(viewModel.hero.heroClass.emoji)
                        .font(.system(size: 40))
                    Text("Lv.\(viewModel.hero.level)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }

            // 名前と職業
            VStack(spacing: 4) {
                Text(viewModel.hero.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(viewModel.hero.heroClass.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label(viewModel.dayCountText, systemImage: "calendar")
                    Text("·")
                    Label(viewModel.hero.condition.rawValue, systemImage: viewModel.hero.condition.systemImageName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Status Detail

    private var statusDetailCard: some View {
        VStack(spacing: 16) {
            Text("ステータス")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // HP
            statusDetailRow(
                emoji: "❤️",
                label: "HP",
                value: viewModel.hero.hp,
                max: viewModel.hero.maxHP,
                color: .red
            )

            // MP
            statusDetailRow(
                emoji: "💎",
                label: "MP",
                value: viewModel.hero.mp,
                max: viewModel.hero.maxMP,
                color: .blue
            )

            Divider()

            // 攻撃・防御
            HStack(spacing: 24) {
                statItem(emoji: "⚔️", label: "攻撃力", value: "\(viewModel.hero.attack)")
                statItem(emoji: "🛡️", label: "防御力", value: "\(viewModel.hero.defense)")
                statItem(emoji: "💰", label: "所持金", value: "\(viewModel.hero.gold)G")
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statusDetailRow(emoji: String, label: String, value: Int, max: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(emoji)
                    .font(.caption)
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text("\(value) / \(max)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / CGFloat(max), height: 10)
                }
            }
            .frame(height: 10)
        }
    }

    private func statItem(emoji: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title3)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Experience

    private var experienceCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("経験値")
                    .font(.headline)
                Spacer()
                Text("次のレベルまで \(viewModel.hero.remainingExp) EXP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 14)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.hero.expProgress, height: 14)
                }
            }
            .frame(height: 14)

            HStack {
                Text("EXP: \(viewModel.hero.experience)")
                    .font(.caption)
                    .monospacedDigit()
                Spacer()
                Text("\(viewModel.hero.expToNextLevel)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Stats Grid

    private var statsGridCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("冒険の記録")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(viewModel.statsSummary, id: \.label) { stat in
                    VStack(spacing: 6) {
                        Text(stat.emoji)
                            .font(.title3)
                        Text(stat.value)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .monospacedDigit()
                        Text(stat.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HeroStatusView(viewModel: WidgetQuestViewModel())
}
