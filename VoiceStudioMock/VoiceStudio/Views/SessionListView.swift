import SwiftUI

/// 録音セッション一覧画面
struct SessionListView: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "セッションなし",
                        systemImage: "waveform",
                        description: Text("収録を開始すると、ここにセッションが表示されます")
                    )
                } else {
                    List {
                        // 統計サマリー
                        Section {
                            SessionSummaryCard(sessions: viewModel.sessions)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                        // セッション一覧
                        Section("録音履歴") {
                            ForEach(viewModel.sessions) { session in
                                SessionRow(session: session)
                            }
                        }
                    }
                }
            }
            .navigationTitle("セッション")
        }
    }
}

// MARK: - Session Summary Card

private struct SessionSummaryCard: View {
    let sessions: [RecordingSession]

    private var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }

    private var totalDurationText: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(sessions.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("エピソード")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                Text(totalDurationText)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("総収録時間")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.purple.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Session Row

private struct SessionRow: View {
    let session: RecordingSession

    var body: some View {
        HStack(spacing: 12) {
            // ステータスアイコン
            Image(systemName: session.status.systemImageName)
                .font(.title3)
                .foregroundStyle(statusColor)
                .frame(width: 32)

            // セッション情報
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Text(session.dateText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let presetName = session.presetName {
                        Text(presetName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.purple.opacity(0.1))
                            .foregroundStyle(.purple)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            // 録音時間
            Text(session.durationText)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch session.status {
        case .recording: .red
        case .paused: .yellow
        case .completed: .green
        case .editing: .purple
        }
    }
}
