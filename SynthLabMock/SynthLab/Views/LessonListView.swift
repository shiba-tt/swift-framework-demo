import SwiftUI

/// レッスン一覧画面
struct LessonListView: View {
    let viewModel: SynthLabViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 進捗サマリー
                    ProgressCard(
                        completed: viewModel.completedLessons.count,
                        total: viewModel.lessons.count
                    )

                    // レッスン一覧
                    ForEach(viewModel.lessons) { lesson in
                        LessonCard(
                            lesson: lesson,
                            isCompleted: viewModel.completedLessons.contains(lesson.number),
                            isCurrent: viewModel.currentLesson?.id == lesson.id
                        ) {
                            viewModel.startLesson(lesson)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("レッスン")
        }
    }
}

// MARK: - Progress Card

private struct ProgressCard: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("学習進捗")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(completed) / \(total)")
                    .font(.headline)
                    .foregroundStyle(.indigo)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.quaternary)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.indigo.gradient)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 12)

            if completed == total && total > 0 {
                Label("全レッスン完了！フリープレイで自由に音作りを楽しみましょう", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Lesson Card

private struct LessonCard: View {
    let lesson: Lesson
    let isCompleted: Bool
    let isCurrent: Bool
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // レッスン番号バッジ
                ZStack {
                    Circle()
                        .fill(isCompleted ? .green : lesson.focusModule.color)
                        .frame(width: 32, height: 32)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(lesson.number)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack(spacing: 4) {
                        Image(systemName: lesson.focusModule.icon)
                            .font(.system(size: 10))
                        Text(lesson.focusModule.rawValue)
                            .font(.caption2)
                    }
                    .foregroundStyle(lesson.focusModule.color)
                }

                Spacer()

                if isCurrent {
                    Text("学習中")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.indigo.opacity(0.15))
                        .foregroundStyle(.indigo)
                        .clipShape(Capsule())
                }
            }

            Text(lesson.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            // ステップ数
            HStack(spacing: 4) {
                Image(systemName: "list.bullet")
                    .font(.caption2)
                Text("\(lesson.steps.count) ステップ")
                    .font(.caption2)
            }
            .foregroundStyle(.tertiary)

            if !isCompleted {
                Button(action: onStart) {
                    Text(isCurrent ? "続きから学習" : "レッスン開始")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(lesson.focusModule.color.opacity(0.15))
                        .foregroundStyle(lesson.focusModule.color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCurrent ? .indigo.opacity(0.3) : .clear, lineWidth: 1)
        )
    }
}
