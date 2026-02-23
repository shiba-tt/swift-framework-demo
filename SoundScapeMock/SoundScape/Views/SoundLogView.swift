import SwiftUI

struct SoundLogView: View {
    @Bindable var viewModel: SoundScapeViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.soundLog.isEmpty {
                    ContentUnavailableView {
                        Label("ログなし", systemImage: "waveform.slash")
                    } description: {
                        Text("分析タブでリスニングを開始すると、環境音のログが記録されます。")
                    }
                } else {
                    logList
                }
            }
            .navigationTitle("環境音ログ")
        }
    }

    // MARK: - Log List

    private var logList: some View {
        List {
            Section {
                todaySummaryRow
            }

            Section("今日の環境音") {
                ForEach(viewModel.soundLog) { entry in
                    logEntryRow(entry)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var todaySummaryRow: some View {
        HStack(spacing: 16) {
            VStack {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundStyle(.cyan)
                Text("合計")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text("今日のリスニング")
                    .font(.subheadline.bold())
                Text(viewModel.totalListeningTimeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(viewModel.soundLog.count)件")
                    .font(.subheadline.bold())
                Text("検出")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func logEntryRow(_ entry: SoundLogEntry) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(entry.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(entry.category.emoji)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.category.rawValue)
                        .font(.subheadline.bold())
                    Spacer()
                    Text(entry.timeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Label(entry.durationText, systemImage: "timer")
                    Label(entry.decibelText, systemImage: "speaker.wave.2")
                    if let location = entry.locationName {
                        Label(location, systemImage: "location")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SoundLogView(viewModel: SoundScapeViewModel())
}
