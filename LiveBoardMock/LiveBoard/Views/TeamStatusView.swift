import SwiftUI

/// チームメンバーのステータス表示画面
struct TeamStatusView: View {
    let viewModel: LiveBoardViewModel

    @State private var selectedMember: TeamMember?
    @State private var showStatusEditor = false
    @State private var editingStatus = ""
    @State private var editingEmoji = "💻"

    private let statusEmojis = ["💻", "🎨", "📞", "🍱", "🧪", "📝", "☕", "🏃", "🤔", "🎯", "🔥", "😴"]

    var body: some View {
        NavigationStack {
            List {
                // オンライン状況サマリー
                Section {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.board.name)
                                .font(.headline)
                            Text("最終同期: \(viewModel.board.lastSyncedText)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                Text("\(viewModel.onlineMemberCount)人オンライン")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            Text("全\(viewModel.members.count)人")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // メンバーリスト
                Section("メンバー") {
                    ForEach(viewModel.members) { member in
                        memberRow(member)
                            .onTapGesture {
                                selectedMember = member
                                editingStatus = member.status
                                editingEmoji = member.statusEmoji
                                showStatusEditor = true
                            }
                    }
                }

                // 進捗サマリー
                Section("タスク進捗") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("完了率")
                                .font(.subheadline)
                            Spacer()
                            Text("\(viewModel.completionPercentage)%")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }

                        ProgressView(value: Double(viewModel.completedTaskCount), total: Double(max(viewModel.tasks.count, 1)))
                            .tint(.blue)

                        HStack {
                            Label("\(viewModel.completedTaskCount) 完了", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Spacer()
                            Label("\(viewModel.pendingTaskCount) 残り", systemImage: "circle")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("チームステータス")
            .refreshable {
                viewModel.refresh()
            }
            .sheet(isPresented: $showStatusEditor) {
                statusEditorSheet
            }
        }
    }

    // MARK: - Member Row

    private func memberRow(_ member: TeamMember) -> some View {
        HStack(spacing: 12) {
            // アバターとオンラインインジケーター
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(String(member.name.prefix(1)))
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }

                Circle()
                    .fill(member.isOnline ? .green : .gray)
                    .frame(width: 12, height: 12)
                    .overlay {
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    }
            }

            // 名前とステータス
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(member.displayStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 更新時刻
            VStack(alignment: .trailing, spacing: 2) {
                Text(member.lastUpdatedText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                if member.isOnline {
                    Text("オンライン")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else {
                    Text("オフライン")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Status Editor Sheet

    private var statusEditorSheet: some View {
        NavigationStack {
            Form {
                if let member = selectedMember {
                    Section("メンバー") {
                        Text(member.name)
                            .font(.headline)
                    }

                    Section("ステータス絵文字") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(statusEmojis, id: \.self) { emoji in
                                Button {
                                    editingEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.title2)
                                        .padding(8)
                                        .background(
                                            editingEmoji == emoji
                                                ? Color.blue.opacity(0.2)
                                                : Color.clear
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Section("ステータスメッセージ") {
                        TextField("ステータスを入力", text: $editingStatus)
                    }
                }
            }
            .navigationTitle("ステータス変更")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        showStatusEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let member = selectedMember {
                            viewModel.updateStatus(
                                memberId: member.id,
                                status: editingStatus,
                                emoji: editingEmoji
                            )
                        }
                        showStatusEditor = false
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
