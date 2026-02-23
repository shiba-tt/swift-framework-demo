import SwiftUI

struct ProjectListView: View {
    @Bindable var viewModel: ReelForgeViewModel

    var body: some View {
        NavigationStack {
            List {
                if viewModel.projects.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.projects) { project in
                        projectRow(project)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteProject(viewModel.projects[index])
                        }
                    }
                }
            }
            .navigationTitle("プロジェクト")
            .sheet(item: $viewModel.selectedProject) { project in
                ProjectDetailView(project: project, viewModel: viewModel)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("プロジェクトなし", systemImage: "film.stack")
        } description: {
            Text("「作成」タブからAIリールを生成してみましょう")
        }
    }

    // MARK: - Project Row

    private func projectRow(_ project: ReelProject) -> some View {
        Button {
            viewModel.selectedProject = project
        } label: {
            HStack(spacing: 12) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(project.status.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    VStack(spacing: 2) {
                        Text(project.status.emoji)
                            .font(.title3)
                        Text(project.totalDurationText)
                            .font(.system(size: 10).bold())
                            .foregroundStyle(.secondary)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.title)
                        .font(.headline)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Label("\(project.clipCount)クリップ", systemImage: "photo.on.rectangle")
                        Label(project.bgmTrack.genre.rawValue, systemImage: "music.note")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Text(project.status.rawValue)
                            .font(.caption2.bold())
                            .foregroundStyle(project.status.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(project.status.color.opacity(0.1), in: Capsule())

                        Text(project.transitionStyle.emoji + " " + project.transitionStyle.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
