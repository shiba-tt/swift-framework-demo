import SwiftUI

// MARK: - MemoListView

struct MemoListView: View {
    @Bindable var viewModel: VoiceMemoAIViewModel
    @Binding var showingRecordView: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // カテゴリフィルター
                categoryFilter

                // メモリスト
                if viewModel.filteredMemos.isEmpty {
                    emptyState
                } else {
                    memoList
                }
            }
            .navigationTitle("VoiceMemo AI")
            .searchable(text: $viewModel.searchText, prompt: "メモを検索")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingRecordView = true
                    } label: {
                        Image(systemName: "mic.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "すべて",
                    emoji: "📋",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }

                ForEach(MemoCategory.allCases) { category in
                    FilterChip(
                        title: category.displayName,
                        emoji: category.emoji,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    // MARK: - Memo List

    private var memoList: some View {
        List {
            ForEach(viewModel.filteredMemos, id: \.id) { memo in
                NavigationLink {
                    MemoDetailView(viewModel: viewModel, memo: memo)
                } label: {
                    MemoRowView(memo: memo)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let memo = viewModel.filteredMemos[index]
                    viewModel.deleteMemo(memo)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "mic.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("メモがありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("マイクボタンをタップして\n音声メモを録音しましょう")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

// MARK: - MemoRowView

struct MemoRowView: View {
    let memo: VoiceMemo

    var body: some View {
        HStack(spacing: 12) {
            // カテゴリアイコン
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill((memo.category?.color ?? .gray).opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(memo.category?.emoji ?? "📋")
                    .font(.title3)
            }

            // メモ情報
            VStack(alignment: .leading, spacing: 4) {
                Text(memo.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                if let summary = memo.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 12) {
                    Label(memo.formattedDate, systemImage: "clock")
                    Label(memo.formattedDuration, systemImage: "waveform")

                    if memo.pendingActionItemsCount > 0 {
                        Label("\(memo.pendingActionItemsCount)", systemImage: "checklist")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.indigo.opacity(0.15) : Color(.systemGray6))
            .foregroundStyle(isSelected ? .indigo : .primary)
            .clipShape(Capsule())
        }
    }
}
