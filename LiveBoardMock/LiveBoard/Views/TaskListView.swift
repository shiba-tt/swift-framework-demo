import SwiftUI

/// タスク一覧画面
struct TaskListView: View {
    let viewModel: LiveBoardViewModel

    @State private var showAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskAssignee = ""
    @State private var filterCompleted: Bool?

    var body: some View {
        NavigationStack {
            List {
                // タスクサマリー
                Section {
                    HStack(spacing: 16) {
                        taskStatCard(
                            title: "全タスク",
                            count: viewModel.tasks.count,
                            color: .blue,
                            icon: "list.bullet"
                        )
                        taskStatCard(
                            title: "完了",
                            count: viewModel.completedTaskCount,
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                        taskStatCard(
                            title: "残り",
                            count: viewModel.pendingTaskCount,
                            color: .orange,
                            icon: "circle"
                        )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // フィルター
                Section {
                    Picker("フィルター", selection: $filterCompleted) {
                        Text("すべて").tag(Optional<Bool>.none)
                        Text("未完了").tag(Optional<Bool>.some(false))
                        Text("完了済み").tag(Optional<Bool>.some(true))
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }

                // タスクリスト
                Section("タスク一覧") {
                    ForEach(filteredTasks) { task in
                        taskRow(task)
                    }
                    .onDelete { indexSet in
                        let tasksToDelete = indexSet.map { filteredTasks[$0] }
                        for task in tasksToDelete {
                            viewModel.removeTask(taskId: task.id)
                        }
                    }
                }
            }
            .navigationTitle("タスク管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                addTaskSheet
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredTasks: [BoardTask] {
        switch filterCompleted {
        case .some(true):
            return viewModel.tasks.filter(\.isCompleted)
        case .some(false):
            return viewModel.tasks.filter { !$0.isCompleted }
        case .none:
            return viewModel.tasks
        }
    }

    // MARK: - Task Stat Card

    private func taskStatCard(title: String, count: Int, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Task Row

    private func taskRow(_ task: BoardTask) -> some View {
        HStack(spacing: 12) {
            // チェックボタン
            Button {
                viewModel.toggleTask(taskId: task.id)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            // タスク情報
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    if let assignee = task.assignee {
                        Label(assignee, systemImage: "person.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    } else {
                        Label("未割り当て", systemImage: "person")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Text(task.shortDateText)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    // MARK: - Add Task Sheet

    private var addTaskSheet: some View {
        NavigationStack {
            Form {
                Section("タスク情報") {
                    TextField("タスク名を入力", text: $newTaskTitle)

                    Picker("担当者", selection: $newTaskAssignee) {
                        Text("未割り当て").tag("")
                        ForEach(viewModel.members) { member in
                            Text(member.name).tag(member.name)
                        }
                    }
                }

                Section {
                    Text("タスクはチーム全員のウィジェットに即座に反映されます。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("タスク追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        resetAddTaskForm()
                        showAddTask = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let assignee = newTaskAssignee.isEmpty ? nil : newTaskAssignee
                        viewModel.addTask(title: newTaskTitle, assignee: assignee)
                        resetAddTaskForm()
                        showAddTask = false
                    }
                    .fontWeight(.bold)
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func resetAddTaskForm() {
        newTaskTitle = ""
        newTaskAssignee = ""
    }
}
