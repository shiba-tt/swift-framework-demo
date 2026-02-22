import SwiftUI

struct HistoryView: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("統計") {
                    HStack(spacing: 16) {
                        StatCard(value: "12", label: "視聴回数", icon: "play.fill", color: .indigo)
                        StatCard(value: "48", label: "リアクション", icon: "face.smiling", color: .orange)
                        StatCard(value: "8.5h", label: "合計時間", icon: "clock.fill", color: .green)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }

                Section("最近の視聴") {
                    ForEach(sampleHistory) { entry in
                        HStack(spacing: 12) {
                            Image(systemName: entry.icon)
                                .font(.title3)
                                .foregroundStyle(.indigo)
                                .frame(width: 40, height: 40)
                                .background(.indigo.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(.body)
                                HStack(spacing: 8) {
                                    Label("\(entry.participants)人", systemImage: "person.2")
                                    Text(entry.date)
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(entry.duration)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("履歴")
        }
    }

    private var sampleHistory: [HistoryEntry] {
        [
            HistoryEntry(
                title: "星を継ぐもの", icon: "star.fill",
                participants: 4, date: "今日", duration: "1:22:00"
            ),
            HistoryEntry(
                title: "ネオンナイト", icon: "bolt.fill",
                participants: 3, date: "昨日", duration: "24:00"
            ),
            HistoryEntry(
                title: "海辺のメロディ", icon: "music.mic",
                participants: 2, date: "2日前", duration: "1:20:00"
            ),
            HistoryEntry(
                title: "東京サンセット", icon: "building.2.fill",
                participants: 4, date: "3日前", duration: "1:30:00"
            ),
            HistoryEntry(
                title: "深海の冒険", icon: "water.waves",
                participants: 3, date: "1週間前", duration: "1:00:00"
            ),
        ]
    }
}

private struct HistoryEntry: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let participants: Int
    let date: String
    let duration: String
}

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
