import SwiftUI

/// スポット一覧画面
struct SpotListView: View {
    @Bindable var viewModel: AdventureViewModel

    var body: some View {
        NavigationStack {
            List {
                // イベント情報
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("まちなか謎解きアドベンチャー")
                            .font(.headline)
                        Text("2026年 春のイベント")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ProgressView(value: viewModel.progressRatio) {
                            HStack {
                                Text("達成度")
                                Spacer()
                                Text("\(Int(viewModel.progressRatio * 100))%")
                            }
                            .font(.caption)
                        }
                        .tint(.orange)

                        HStack {
                            Label("\(viewModel.currentProgress?.clearedCount ?? 0) クリア", systemImage: "checkmark.circle")
                            Spacer()
                            Label("\(viewModel.currentProgress?.totalPoints ?? 0) pt", systemImage: "star.fill")
                                .foregroundStyle(.orange)
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                }

                // スポットリスト
                Section("スポット") {
                    ForEach(viewModel.spots) { spot in
                        spotRow(spot)
                    }
                }
            }
            .navigationTitle("スポット一覧")
        }
    }

    private func spotRow(_ spot: PuzzleSpot) -> some View {
        HStack {
            // 順番
            ZStack {
                Circle()
                    .fill(viewModel.isSpotCleared(spot) ? Color.green : Color.orange)
                    .frame(width: 36, height: 36)

                if viewModel.isSpotCleared(spot) {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                } else {
                    Text("\(spot.order)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(spot.spotDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if !viewModel.isSpotCleared(spot) {
                Button("挑戦") {
                    viewModel.startPuzzle(at: spot)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}
