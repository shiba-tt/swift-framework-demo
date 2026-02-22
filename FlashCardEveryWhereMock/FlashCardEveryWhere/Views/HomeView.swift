import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: FlashCardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    streakBanner()
                    todaySummarySection()
                    quickStudySection()
                    deckOverviewSection()
                }
                .padding()
            }
            .navigationTitle("FlashCard EveryWhere")
        }
    }

    // MARK: - Streak Banner

    private func streakBanner() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.streakDays)日連続学習中！")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("毎日の積み重ねが力になります")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
        }
        .padding()
        .background(
            LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Today Summary

    private func todaySummarySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日のサマリー")
                .font(.headline)

            HStack(spacing: 12) {
                statCard(title: "学習済み", value: "\(viewModel.todayStudiedCount)枚", icon: "checkmark.circle.fill", color: .green)
                statCard(title: "残り復習", value: "\(viewModel.totalDueCards)枚", icon: "clock.fill", color: .orange)
                statCard(title: "習得率", value: viewModel.masteryText, icon: "star.fill", color: .yellow)
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Quick Study

    private func quickStudySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイック学習")
                .font(.headline)

            if viewModel.totalDueCards > 0 {
                Button {
                    viewModel.startStudy()
                    viewModel.selectedTab = .study
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("復習を始める（\(viewModel.totalDueCards)枚）")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("今日の復習は完了しました！")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Deck Overview

    private func deckOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("デッキ一覧")
                .font(.headline)

            ForEach(viewModel.decks) { deck in
                deckRow(deck)
            }
        }
    }

    private func deckRow(_ deck: Deck) -> some View {
        HStack(spacing: 12) {
            Image(systemName: deck.category.icon)
                .font(.title2)
                .foregroundStyle(deck.category.color)
                .frame(width: 44, height: 44)
                .background(deck.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(deck.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(deck.totalCards)枚 · 習得 \(deck.masteredCount)/\(deck.totalCards)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if deck.dueCards > 0 {
                Text("\(deck.dueCards)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(.white)
                    .background(.red, in: Capsule())
            }
        }
        .padding(12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
    }
}
