import SwiftUI

// MARK: - メインコンテンツビュー

/// アプリのルートビュー
struct ContentView: View {
    @State private var viewModel = TimerViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.orange.opacity(0.05),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.activeTimers.isEmpty {
                    // タイマーがない場合のプレースホルダー
                    EmptyTimerView(viewModel: viewModel)
                } else {
                    // アクティブタイマー一覧
                    TimerListView(viewModel: viewModel)
                }
            }
            .navigationTitle("CookMaster")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showingPresetSelection = true
                        } label: {
                            Label("プリセットから追加", systemImage: "list.bullet")
                        }

                        Button {
                            viewModel.showingAddTimer = true
                        } label: {
                            Label("カスタムタイマー", systemImage: "timer")
                        }

                        if !viewModel.activeTimers.isEmpty {
                            Divider()
                            Button(role: .destructive) {
                                Task { await viewModel.cancelAllTimers() }
                            } label: {
                                Label("すべてキャンセル", systemImage: "xmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.orange)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.activeTimerCount > 0 {
                        Text("\(viewModel.activeTimerCount)個のタイマー")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddTimer) {
                AddTimerView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingPresetSelection) {
                PresetSelectionView(viewModel: viewModel)
            }
            .alert("エラー", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .task {
            await viewModel.setup()
        }
    }
}

// MARK: - 空状態ビュー

/// タイマーがない場合に表示するプレースホルダー
struct EmptyTimerView: View {
    let viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "frying.pan")
                .font(.system(size: 64))
                .foregroundStyle(.orange.opacity(0.6))

            VStack(spacing: 8) {
                Text("タイマーがありません")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("料理タイマーを追加して\nマルチタイマーで料理を管理しましょう")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button {
                    viewModel.showingPresetSelection = true
                } label: {
                    Label("プリセットから追加", systemImage: "list.bullet")
                        .frame(maxWidth: 240)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Button {
                    viewModel.showingAddTimer = true
                } label: {
                    Label("カスタムタイマー", systemImage: "timer")
                        .frame(maxWidth: 240)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }

            if !viewModel.isAuthorized {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text("アラーム権限が許可されていません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
