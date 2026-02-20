import SwiftUI

// MARK: - タイマーリストビュー

/// アクティブなタイマーをリスト表示するビュー
struct TimerListView: View {
    let viewModel: TimerViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // アラート中のタイマー（完了通知）
                if !viewModel.alertingTimers.isEmpty {
                    Section {
                        ForEach(viewModel.alertingTimers) { timer in
                            TimerCardView(
                                timer: timer,
                                viewModel: viewModel,
                                style: .alerting
                            )
                        }
                    } header: {
                        SectionHeaderView(
                            title: "完了!",
                            systemImage: "bell.fill",
                            color: .red
                        )
                    }
                }

                // カウントダウン中のタイマー
                if !viewModel.countingTimers.isEmpty {
                    Section {
                        ForEach(viewModel.countingTimers) { timer in
                            TimerCardView(
                                timer: timer,
                                viewModel: viewModel,
                                style: .counting
                            )
                        }
                    } header: {
                        SectionHeaderView(
                            title: "調理中",
                            systemImage: "flame.fill",
                            color: .orange
                        )
                    }
                }

                // 一時停止中のタイマー
                if !viewModel.pausedTimers.isEmpty {
                    Section {
                        ForEach(viewModel.pausedTimers) { timer in
                            TimerCardView(
                                timer: timer,
                                viewModel: viewModel,
                                style: .paused
                            )
                        }
                    } header: {
                        SectionHeaderView(
                            title: "一時停止中",
                            systemImage: "pause.circle.fill",
                            color: .secondary
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 100) // FAB のスペース確保
        }
        .overlay(alignment: .bottom) {
            // フローティングアクションボタン
            QuickAddButton(viewModel: viewModel)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - セクションヘッダー

struct SectionHeaderView: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}

// MARK: - クイック追加ボタン

struct QuickAddButton: View {
    let viewModel: TimerViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.showingPresetSelection = true
            } label: {
                Label("プリセット", systemImage: "list.bullet")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            Button {
                viewModel.showingAddTimer = true
            } label: {
                Label("カスタム", systemImage: "plus")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}
