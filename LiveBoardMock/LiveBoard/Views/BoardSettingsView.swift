import SwiftUI

/// ボード設定画面
struct BoardSettingsView: View {
    let viewModel: LiveBoardViewModel

    @State private var editingBoardName: String = ""
    @State private var showAddMember = false
    @State private var newMemberName = ""
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                // ボード情報
                Section("ボード情報") {
                    HStack {
                        Label("ボード名", systemImage: "rectangle.3.group")
                        Spacer()
                        TextField("ボード名", text: $editingBoardName)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                            .onSubmit {
                                if !editingBoardName.trimmingCharacters(in: .whitespaces).isEmpty {
                                    viewModel.updateBoardName(editingBoardName)
                                }
                            }
                    }

                    HStack {
                        Label("メンバー数", systemImage: "person.3")
                        Spacer()
                        Text("\(viewModel.members.count)人")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("タスク数", systemImage: "checklist")
                        Spacer()
                        Text("\(viewModel.tasks.count)件")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("最終同期", systemImage: "arrow.triangle.2.circlepath")
                        Spacer()
                        Text(viewModel.board.lastSyncedText)
                            .foregroundStyle(.secondary)
                    }
                }

                // メンバー管理
                Section {
                    ForEach(viewModel.members) { member in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(member.isOnline ? .green : .gray)
                                .frame(width: 8, height: 8)

                            Text(member.name)
                                .font(.subheadline)

                            Spacer()

                            Text(member.displayStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        let membersToDelete = indexSet.map { viewModel.members[$0] }
                        for member in membersToDelete {
                            viewModel.removeMember(memberId: member.id)
                        }
                    }

                    Button {
                        showAddMember = true
                    } label: {
                        Label("メンバーを追加", systemImage: "person.badge.plus")
                    }
                } header: {
                    Text("メンバー管理")
                } footer: {
                    Text("左スワイプでメンバーを削除できます。")
                }

                // ウィジェット情報
                Section("ウィジェット") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Widget Push Updates", systemImage: "arrow.up.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("サーバーからのプッシュ通知でウィジェットがリアルタイムに更新されます。チームの最新状況が常にホーム画面に表示されます。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("対応ウィジェットサイズ", systemImage: "rectangle.3.group.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        VStack(alignment: .leading, spacing: 4) {
                            widgetInfoRow("小", description: "チーム活動サマリー")
                            widgetInfoRow("中", description: "メンバーステータス + タスク概要")
                            widgetInfoRow("大", description: "フルダッシュボード（インタラクティブ）")
                            widgetInfoRow("円形", description: "オンライン人数")
                            widgetInfoRow("矩形", description: "ミニタスクリスト")
                            widgetInfoRow("インライン", description: "チーム名 + オンライン数")
                        }
                    }
                    .padding(.vertical, 4)
                }

                // ライブアクティビティ
                Section("ライブアクティビティ") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("スプリントカウントダウン", systemImage: "timer")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("スプリント期間中、残り時間とチームの進捗状況をロック画面やDynamic Islandに表示します。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // データリセット
                Section {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("データをリセット", systemImage: "trash")
                    }
                } footer: {
                    Text("すべてのボードデータを削除し、デモデータで再初期化します。")
                }
            }
            .navigationTitle("ボード設定")
            .onAppear {
                editingBoardName = viewModel.board.name
            }
            .alert("データリセット", isPresented: $showResetConfirm) {
                Button("キャンセル", role: .cancel) {}
                Button("リセット", role: .destructive) {
                    // UserDefaults のデータをクリア
                    if let defaults = UserDefaults(suiteName: "group.com.example.liveboard") {
                        defaults.removeObject(forKey: "teamBoard")
                    }
                    Task {
                        await viewModel.initialize()
                        editingBoardName = viewModel.board.name
                    }
                }
            } message: {
                Text("すべてのデータが削除されます。この操作は取り消せません。")
            }
            .sheet(isPresented: $showAddMember) {
                addMemberSheet
            }
        }
    }

    // MARK: - Widget Info Row

    private func widgetInfoRow(_ size: String, description: String) -> some View {
        HStack(spacing: 8) {
            Text(size)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .leading)
                .foregroundStyle(.blue)

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Add Member Sheet

    private var addMemberSheet: some View {
        NavigationStack {
            Form {
                Section("新しいメンバー") {
                    TextField("名前を入力", text: $newMemberName)
                }

                Section {
                    Text("追加されたメンバーは即座にチームボードとウィジェットに反映されます。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("メンバー追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        newMemberName = ""
                        showAddMember = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        viewModel.addMember(name: newMemberName)
                        newMemberName = ""
                        showAddMember = false
                    }
                    .fontWeight(.bold)
                    .disabled(newMemberName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
