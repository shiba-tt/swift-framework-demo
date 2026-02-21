import SwiftUI

/// メインのクエスト画面（イベント表示・選択肢）
struct QuestView: View {
    @Bindable var viewModel: WidgetQuestViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroSummaryCard
                    locationCard
                    eventCard
                    if viewModel.showingResult {
                        resultCard
                    }
                }
                .padding()
            }
            .navigationTitle("冒険")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Hero Summary

    private var heroSummaryCard: some View {
        HStack(spacing: 16) {
            // レベル・クラス
            VStack(spacing: 4) {
                Text(viewModel.hero.heroClass.emoji)
                    .font(.system(size: 32))
                Text("Lv.\(viewModel.hero.level)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            // ステータスバー
            VStack(spacing: 8) {
                statusBar(label: "HP", value: viewModel.hero.hp, max: viewModel.hero.maxHP, color: .red)
                statusBar(label: "MP", value: viewModel.hero.mp, max: viewModel.hero.maxMP, color: .blue)
            }

            Spacer()

            // ゴールド
            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.dayCountText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    Text("💰")
                        .font(.caption)
                    Text("\(viewModel.hero.gold)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Location

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("現在地")
                    .font(.headline)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableLocations) { location in
                        locationButton(for: location)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func locationButton(for location: QuestLocation) -> some View {
        let isSelected = location.id == viewModel.currentLocation.id

        return Button {
            viewModel.changeLocation(to: location)
        } label: {
            VStack(spacing: 6) {
                Text(location.emoji)
                    .font(.title2)
                Text(location.name)
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text(location.difficultyText)
                    .font(.system(size: 8))
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(isSelected ? Color.indigo.opacity(0.2) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Event

    private var eventCard: some View {
        VStack(spacing: 16) {
            if let event = viewModel.currentEvent {
                // イベントヘッダー
                HStack {
                    Text(event.type.emoji)
                        .font(.title)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.headline)
                        Text(viewModel.currentLocation.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(event.timeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // イベント説明
                Text(event.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // 選択肢
                if !viewModel.showingResult {
                    ForEach(event.choices) { choice in
                        choiceButton(for: choice)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("次のイベントを待っています...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func choiceButton(for choice: EventChoice) -> some View {
        Button {
            viewModel.selectChoice(choice)
        } label: {
            HStack {
                Text(choice.emoji)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(choice.label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(choice.effectSummary)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color.indigo.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Result

    private var resultCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(.green)

            Text(viewModel.lastChoiceResult ?? "")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            Button {
                viewModel.generateNewEvent()
            } label: {
                Text("次のイベントへ")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func statusBar(label: String, value: Int, max: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .frame(width: 24, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / CGFloat(max), height: 8)
                }
            }
            .frame(height: 8)

            Text("\(value)/\(max)")
                .font(.caption2)
                .monospacedDigit()
                .frame(width: 56, alignment: .trailing)
        }
    }
}

#Preview {
    QuestView(viewModel: WidgetQuestViewModel())
}
