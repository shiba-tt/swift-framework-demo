import SwiftUI

struct StatsView: View {
    @Bindable var viewModel: FlashCardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overallStatsSection()
                    difficultyBreakdownSection()
                    deckMasterySection()
                    weeklyActivitySection()
                }
                .padding()
            }
            .navigationTitle("統計")
        }
    }

    // MARK: - Overall Stats

    private func overallStatsSection() -> some View {
        VStack(spacing: 16) {
            Text("全体の習得状況")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            masteryGauge()

            HStack(spacing: 16) {
                statsItem(title: "総カード数", value: "\(viewModel.totalCards)", icon: "rectangle.stack.fill")
                statsItem(title: "要復習", value: "\(viewModel.totalDueCards)", icon: "clock.fill")
                statsItem(title: "連続学習", value: "\(viewModel.streakDays)日", icon: "flame.fill")
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func masteryGauge() -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(.fill.secondary, lineWidth: 12)
                Circle()
                    .trim(from: 0, to: viewModel.overallMastery)
                    .stroke(
                        AngularGradient(
                            colors: [.red, .orange, .yellow, .green],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text(viewModel.masteryText)
                        .font(.system(size: 32, weight: .bold))
                    Text("習得率")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 120)
        }
    }

    private func statsItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Difficulty Breakdown

    private func difficultyBreakdownSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("難易度別分布")
                .font(.headline)

            ForEach(viewModel.cardsByDifficulty, id: \.difficulty) { item in
                difficultyBar(item.difficulty, count: item.count)
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func difficultyBar(_ difficulty: CardDifficulty, count: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: difficulty.icon)
                .foregroundStyle(difficulty.color)
                .frame(width: 20)

            Text(difficulty.displayName)
                .font(.subheadline)
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                let maxWidth = geo.size.width
                let ratio = viewModel.totalCards > 0 ? CGFloat(count) / CGFloat(viewModel.totalCards) : 0
                RoundedRectangle(cornerRadius: 4)
                    .fill(difficulty.color)
                    .frame(width: maxWidth * ratio)
            }
            .frame(height: 20)

            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 30, alignment: .trailing)
        }
    }

    // MARK: - Deck Mastery

    private func deckMasterySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("デッキ別習得率")
                .font(.headline)

            ForEach(viewModel.decks) { deck in
                deckMasteryRow(deck)
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func deckMasteryRow(_ deck: Deck) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: deck.category.icon)
                    .foregroundStyle(deck.category.color)
                Text(deck.name)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(deck.averageMastery * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
            }

            ProgressView(value: deck.averageMastery)
                .tint(deck.averageMastery >= 0.85 ? .green : deck.averageMastery >= 0.5 ? .orange : .red)
        }
    }

    // MARK: - Weekly Activity

    private func weeklyActivitySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週の学習記録")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(weekDays(), id: \.self) { day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(activityColor(for: day))
                            .frame(height: 40)

                        Text(dayLabel(day))
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func weekDays() -> [Date] {
        let calendar = Calendar.current
        let today = Date.now
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -(6 - offset), to: today)
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private func activityColor(for date: Date) -> Color {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return .green
        }
        let dayOfWeek = calendar.component(.weekday, from: date)
        // サンプルデータ: 過去1週間の学習アクティビティをシミュレート
        switch dayOfWeek {
        case 1: return .green.opacity(0.3) // 日
        case 2: return .green.opacity(0.7) // 月
        case 3: return .green.opacity(0.5) // 火
        case 4: return .green.opacity(0.9) // 水
        case 5: return .green.opacity(0.4) // 木
        case 6: return .green.opacity(0.8) // 金
        case 7: return .green.opacity(0.6) // 土
        default: return .fill.tertiary
        }
    }
}
