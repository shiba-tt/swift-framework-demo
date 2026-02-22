import SwiftUI

struct SharedTasksView: View {
    @Bindable var viewModel: SyncLifeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    pendingTasksCard
                    completedTasksCard
                }
                .padding()
            }
            .navigationTitle("\u{5171}\u{6709}\u{30BF}\u{30B9}\u{30AF}")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Pending Tasks

    private var pendingTasksCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\u{672A}\u{5B8C}\u{4E86}")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.pendingTasks.count)\u{4EF6}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if viewModel.pendingTasks.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("\u{3059}\u{3079}\u{3066}\u{5B8C}\u{4E86}\u{3057}\u{307E}\u{3057}\u{305F}")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                ForEach(viewModel.pendingTasks) { task in
                    TaskRow(task: task) {
                        viewModel.toggleTaskCompletion(task)
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Completed Tasks

    private var completedTasksCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\u{5B8C}\u{4E86}\u{6E08}\u{307F}")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.completedTasks.count)\u{4EF6}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.completedTasks) { task in
                TaskRow(task: task) {
                    viewModel.toggleTaskCompletion(task)
                }
                .opacity(0.6)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }
}

// MARK: - Task Row

private struct TaskRow: View {
    let task: SharedTask
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }

            Image(systemName: task.category.icon)
                .font(.caption)
                .foregroundStyle(task.category.color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(task.isCompleted)

                HStack(spacing: 8) {
                    if let assignee = task.assignee {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(assignee.color.opacity(0.3))
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Text(assignee.initials)
                                        .font(.system(size: 7))
                                        .fontWeight(.bold)
                                        .foregroundStyle(assignee.color)
                                )
                            Text(assignee.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("\u{672A}\u{5272}\u{5F53}")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    if let dueText = task.dueDateText {
                        Text(dueText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    }
}

#Preview {
    SharedTasksView(viewModel: SyncLifeViewModel())
}
