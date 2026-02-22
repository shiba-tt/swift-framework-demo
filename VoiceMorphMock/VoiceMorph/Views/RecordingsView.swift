import SwiftUI

struct RecordingsView: View {
    @Bindable var viewModel: VoiceMorphViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.recordings.isEmpty {
                    emptyState
                } else {
                    recordingsList
                }
            }
            .navigationTitle("録音一覧")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("録音なし", systemImage: "waveform.slash")
        } description: {
            Text("モーフタブでマイクを開始し、録音ボタンを押して録音を作成しましょう。")
        }
    }

    // MARK: - Recordings List

    private var recordingsList: some View {
        List {
            Section {
                ForEach(viewModel.recordings) { recording in
                    recordingRow(recording)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let recording = viewModel.recordings[index]
                        viewModel.deleteRecording(recording)
                    }
                }
            } header: {
                Text("\(viewModel.recordings.count) 件の録音")
            }
        }
    }

    private func recordingRow(_ recording: Recording) -> some View {
        HStack(spacing: 12) {
            // 再生ボタン（モック）
            Button {
                // モック: 再生機能
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.purple)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(recording.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Label(recording.presetName, systemImage: "waveform")
                        .font(.caption)
                        .foregroundStyle(.purple)

                    Text(recording.durationText)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(recording.relativeTimeText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                // 共有ボタン（モック）
                Button {
                    // モック: 共有機能
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecordingsView(viewModel: VoiceMorphViewModel())
}
