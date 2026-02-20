import SwiftUI

// MARK: - タイマーカードスタイル

enum TimerCardStyle {
    case counting
    case paused
    case alerting
}

// MARK: - タイマーカードビュー

/// 個々のタイマーをカード形式で表示するビュー
struct TimerCardView: View {
    let timer: CookingTimer
    let viewModel: TimerViewModel
    let style: TimerCardStyle

    @State private var showingCancelConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // メインカード
            HStack(spacing: 16) {
                // カテゴリアイコン + 絵文字
                categoryIcon

                // タイマー情報
                VStack(alignment: .leading, spacing: 4) {
                    Text(timer.name)
                        .font(.headline)
                        .lineLimit(1)

                    Text(timer.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let note = timer.note, !note.isEmpty {
                        Text(note)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // 残り時間表示
                timeDisplay
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // プログレスバー
            if style == .counting {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(height: 3)

                        Rectangle()
                            .fill(progressColor)
                            .frame(
                                width: geometry.size.width * timer.progress,
                                height: 3
                            )
                            .animation(.linear(duration: 1.0), value: timer.progress)
                    }
                }
                .frame(height: 3)
            }

            // アクションボタン
            actionButtons
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(borderColor, lineWidth: style == .alerting ? 2 : 0.5)
        )
        .shadow(color: shadowColor, radius: style == .alerting ? 8 : 4, y: 2)
        .confirmationDialog(
            "タイマーをキャンセルしますか？",
            isPresented: $showingCancelConfirm,
            titleVisibility: .visible
        ) {
            Button("キャンセル", role: .destructive) {
                Task { await viewModel.cancelTimer(timer) }
            }
            Button("戻る", role: .cancel) {}
        }
    }

    // MARK: - カテゴリアイコン

    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 48, height: 48)

            Text(timer.category.emoji)
                .font(.title2)
        }
    }

    // MARK: - 時間表示

    private var timeDisplay: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(timer.formattedRemainingTime)
                .font(.system(.title, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(timeColor)

            Text(style == .alerting ? "完了!" : "残り")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - アクションボタン

    private var actionButtons: some View {
        HStack(spacing: 8) {
            switch style {
            case .counting:
                Button {
                    Task { await viewModel.pauseTimer(timer) }
                } label: {
                    Label("一時停止", systemImage: "pause.fill")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)

                Spacer()

                Button {
                    showingCancelConfirm = true
                } label: {
                    Label("キャンセル", systemImage: "xmark")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .tint(.red)

            case .paused:
                Button {
                    Task { await viewModel.resumeTimer(timer) }
                } label: {
                    Label("再開", systemImage: "play.fill")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Spacer()

                Button {
                    showingCancelConfirm = true
                } label: {
                    Label("キャンセル", systemImage: "xmark")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .tint(.red)

            case .alerting:
                Button {
                    Task { await viewModel.stopTimer(timer) }
                } label: {
                    Label("完了", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Spacer()

                Button {
                    Task {
                        await CookingAlarmManager.shared.extendTimer(
                            id: timer.id,
                            additionalSeconds: 60
                        )
                    }
                } label: {
                    Label("+1分追加", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
    }

    // MARK: - スタイル計算

    private var progressColor: Color {
        if timer.progress > 0.9 {
            return .red
        } else if timer.progress > 0.7 {
            return .orange
        } else {
            return .green
        }
    }

    private var cardBackground: some ShapeStyle {
        switch style {
        case .counting:
            return AnyShapeStyle(.background)
        case .paused:
            return AnyShapeStyle(Color(.systemGray6))
        case .alerting:
            return AnyShapeStyle(Color.red.opacity(0.05))
        }
    }

    private var borderColor: Color {
        switch style {
        case .counting:  return .orange.opacity(0.3)
        case .paused:    return .secondary.opacity(0.3)
        case .alerting:  return .red.opacity(0.5)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .counting:  return .orange.opacity(0.1)
        case .paused:    return .clear
        case .alerting:  return .red.opacity(0.2)
        }
    }

    private var iconBackgroundColor: Color {
        switch style {
        case .counting:  return .orange.opacity(0.15)
        case .paused:    return .secondary.opacity(0.15)
        case .alerting:  return .red.opacity(0.15)
        }
    }

    private var timeColor: Color {
        switch style {
        case .counting:
            return timer.progress > 0.9 ? .red : .primary
        case .paused:
            return .secondary
        case .alerting:
            return .red
        }
    }
}
