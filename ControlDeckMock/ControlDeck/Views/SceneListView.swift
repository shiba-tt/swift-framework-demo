import SwiftUI

// MARK: - SceneListView

struct SceneListView: View {
    @Bindable var viewModel: ControlDeckViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 説明ヘッダー
                    descriptionHeader

                    // シーン一覧
                    ForEach(viewModel.scenes) { scene in
                        SceneCardView(viewModel: viewModel, scene: scene)
                    }

                    // Controls 説明
                    controlsInfoCard
                }
                .padding()
            }
            .navigationTitle("シーン")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Description Header

    private var descriptionHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.title)
                .foregroundStyle(.cyan)

            VStack(alignment: .leading, spacing: 4) {
                Text("シーンで一括操作")
                    .font(.headline)
                Text("複数のデバイスをワンタップで制御。\nコントロールセンターやAction ボタンにも配置可能。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.cyan.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Controls Info

    private var controlsInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "switch.2")
                    .foregroundStyle(.purple)
                Text("iOS 18 Controls")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                ControlInfoRow(
                    icon: "slider.horizontal.below.rectangle",
                    title: "コントロールセンター",
                    description: "スワイプで即座にデバイスを操作"
                )
                ControlInfoRow(
                    icon: "lock.fill",
                    title: "ロック画面",
                    description: "アンロック不要でクイックアクション"
                )
                ControlInfoRow(
                    icon: "button.programmable",
                    title: "Action ボタン",
                    description: "物理ボタンにシーンを割り当て"
                )
            }
        }
        .padding()
        .background(.purple.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - SceneCardView

struct SceneCardView: View {
    @Bindable var viewModel: ControlDeckViewModel
    let scene: HomeScene

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // アイコン
                ZStack {
                    Circle()
                        .fill(scene.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: scene.icon)
                        .font(.title2)
                        .foregroundStyle(scene.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(scene.name)
                        .font(.headline)
                    Text(scene.actionSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if scene.isActive {
                    Label("実行中", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            // アクション詳細
            VStack(alignment: .leading, spacing: 6) {
                ForEach(scene.actions) { action in
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(action.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 実行ボタン
            Button {
                viewModel.executeScene(scene)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(scene.isActive ? "再実行" : "実行")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(scene.color.opacity(0.12))
                .foregroundStyle(scene.color)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - ControlInfoRow

struct ControlInfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
