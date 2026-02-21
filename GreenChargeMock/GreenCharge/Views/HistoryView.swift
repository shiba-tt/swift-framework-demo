import SwiftUI

/// 充電履歴ビュー
struct HistoryView: View {
    let viewModel: GreenChargeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.chargingSessions.isEmpty {
                        EmptyHistoryView()
                    } else {
                        // 統計ヘッダー
                        HistoryStatsHeader(sessions: viewModel.chargingSessions)

                        // セッション一覧
                        ForEach(viewModel.chargingSessions) { session in
                            SessionCard(session: session)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("充電履歴")
        }
    }
}

// MARK: - Stats Header

private struct HistoryStatsHeader: View {
    let sessions: [ChargingSession]

    private var totalEnergy: Double {
        sessions.reduce(0) { $0 + $1.energyKWh }
    }

    private var averageClean: Double {
        let completed = sessions.filter { $0.status == .completed }
        guard !completed.isEmpty else { return 0 }
        return completed.reduce(0) { $0 + $1.averageCleanFraction } / Double(completed.count)
    }

    private var totalPoints: Int {
        sessions.reduce(0) { $0 + $1.earnedPoints }
    }

    var body: some View {
        HStack(spacing: 16) {
            HistoryStat(
                label: "総充電量",
                value: String(format: "%.0f kWh", totalEnergy),
                color: .green
            )
            HistoryStat(
                label: "平均クリーン率",
                value: "\(Int(averageClean * 100))%",
                color: .blue
            )
            HistoryStat(
                label: "獲得 pt",
                value: "\(totalPoints)",
                color: .orange
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct HistoryStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Card

private struct SessionCard: View {
    let session: ChargingSession

    var body: some View {
        HStack(spacing: 12) {
            // ステータスアイコン
            Image(systemName: session.status.systemImageName)
                .font(.title3)
                .foregroundStyle(statusColor)
                .frame(width: 36, height: 36)
                .background(statusColor.opacity(0.1))
                .clipShape(Circle())

            // 情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(dateText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(session.status.rawValue)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }

                HStack(spacing: 12) {
                    Label(session.energyText, systemImage: "bolt.fill")
                    Label(session.cleanPercentText, systemImage: "leaf.fill")
                    if session.earnedPoints > 0 {
                        Label("+\(session.earnedPoints) pt", systemImage: "star.fill")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: session.startDate)
    }

    private var statusColor: Color {
        switch session.status {
        case .scheduled: .blue
        case .charging: .green
        case .completed: .secondary
        case .cancelled: .red
        }
    }
}

// MARK: - Empty State

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bolt.car.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("充電履歴がありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("充電を開始するとここに表示されます")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 60)
    }
}
