import SwiftUI

// MARK: - DreamListView（夢一覧）

struct DreamListView: View {
    @Bindable var viewModel: DreamJournalViewModel
    @State private var showingRecordSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredDreams.isEmpty {
                    emptyStateView
                } else {
                    dreamListContent
                }
            }
            .navigationTitle("DreamJournal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingRecordSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    emotionFilterMenu
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "夢を検索...")
            .sheet(isPresented: $showingRecordSheet) {
                RecordDreamView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Dream List Content

    private var dreamListContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // AI 分析中のバナー
                if viewModel.isAnalyzing {
                    AnalyzingBannerView(progress: viewModel.analysisProgress)
                }

                // Foundation Models 利用不可バナー
                if !viewModel.isModelAvailable {
                    ModelUnavailableBannerView()
                }

                ForEach(viewModel.filteredDreams) { dream in
                    NavigationLink {
                        DreamDetailView(dream: dream, viewModel: viewModel)
                    } label: {
                        DreamCardView(dream: dream)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple.opacity(0.6))

            Text("まだ夢が記録されていません")
                .font(.title2)
                .fontWeight(.semibold)

            Text("起床直後に音声で夢を記録しましょう。\nAI が夢のテーマ・感情・シンボルを\n自動で分析します。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingRecordSheet = true
            } label: {
                Label("夢を記録する", systemImage: "mic.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // MARK: - Emotion Filter Menu

    private var emotionFilterMenu: some View {
        Menu {
            Button {
                viewModel.selectedEmotionFilter = nil
            } label: {
                Label("すべて", systemImage: viewModel.selectedEmotionFilter == nil ? "checkmark" : "")
            }

            Divider()

            ForEach(EmotionalTone.allCases, id: \.rawValue) { tone in
                Button {
                    viewModel.selectedEmotionFilter = tone
                } label: {
                    Label(
                        "\(tone.emoji) \(tone.displayName)",
                        systemImage: viewModel.selectedEmotionFilter == tone ? "checkmark" : ""
                    )
                }
            }
        } label: {
            Image(systemName: viewModel.selectedEmotionFilter == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
    }
}

// MARK: - DreamCardView（夢カード）

struct DreamCardView: View {
    let dream: DreamEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // ヘッダー
            HStack {
                Text(dream.emotionalToneEmoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(dream.displayTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(dream.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if dream.isAnalyzed {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.purple)
                } else {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            // 物語の抜粋
            if let narrative = dream.narrative {
                Text(narrative)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                Text(dream.rawTranscription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // テーマタグ
            if !dream.themes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(dream.themes, id: \.self) { theme in
                            Text(theme)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.purple.opacity(0.1))
                                .foregroundStyle(.purple)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // メタ情報
            HStack(spacing: 12) {
                Label("\(dream.lucidity)", systemImage: "eye")
                Label("\(dream.vividness)", systemImage: "paintbrush")

                if let tone = dream.emotionalTone {
                    Text(tone.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(tone.colorName).opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - AnalyzingBannerView

struct AnalyzingBannerView: View {
    let progress: String?

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(.purple)

            VStack(alignment: .leading) {
                Text("Foundation Models で分析中")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let progress {
                    Text(progress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "sparkles")
                .foregroundStyle(.purple)
        }
        .padding()
        .background(.purple.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ModelUnavailableBannerView

struct ModelUnavailableBannerView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            VStack(alignment: .leading) {
                Text("AI 分析が利用できません")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Apple Intelligence 対応デバイスが必要です")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
