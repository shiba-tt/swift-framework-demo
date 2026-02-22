import SwiftUI

/// コミュニケーション分析画面 — 電話・メッセージの詳細統計
struct CommunicationView: View {
    let viewModel: SocialPulseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if let record = viewModel.todayRecord, let score = viewModel.currentScore {
                    VStack(spacing: 20) {
                        // コミュニケーションレベル
                        CommunicationLevelCard(record: record, score: score)

                        // 電話統計
                        PhoneStatsCard(record: record, phoneScore: score.phoneScore)

                        // メッセージ統計
                        MessageStatsCard(record: record, messageScore: score.messageScore)

                        // 連絡先の多様性
                        ContactDiversityCard(record: record)

                        // コミュニケーションの双方向性
                        BidirectionalCard(record: record)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "データなし",
                        systemImage: "phone.slash",
                        description: Text("コミュニケーションデータがまだ収集されていません")
                    )
                }
            }
            .navigationTitle("コミュニケーション")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Communication Level Card

private struct CommunicationLevelCard: View {
    let record: CommunicationRecord
    let score: SocialScore

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: record.activityLevel.systemImageName)
                .font(.largeTitle)
                .foregroundStyle(Color(record.activityLevel.colorName))
                .frame(width: 60, height: 60)
                .background(Color(record.activityLevel.colorName).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("今日のコミュニケーション")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(record.activityLevel.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(record.activityLevel.colorName))
                Text("電話 \(record.totalCalls) 回 / メッセージ \(record.totalMessages) 通")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Phone Stats Card

private struct PhoneStatsCard: View {
    let record: CommunicationRecord
    let phoneScore: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundStyle(.blue)
                Text("電話")
                    .font(.headline)
                Spacer()
                Text("スコア: \(phoneScore)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }

            // 発信・着信のバー
            VStack(spacing: 12) {
                PhoneStatRow(
                    label: "発信",
                    value: record.outgoingCalls,
                    maxValue: max(record.outgoingCalls, record.incomingCalls),
                    color: .blue,
                    systemImage: "phone.arrow.up.right.fill"
                )
                PhoneStatRow(
                    label: "着信",
                    value: record.incomingCalls,
                    maxValue: max(record.outgoingCalls, record.incomingCalls),
                    color: .cyan,
                    systemImage: "phone.arrow.down.left.fill"
                )
            }

            Divider()

            // 通話時間
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("合計通話時間")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(record.callDurationMinutes)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("分")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("平均通話時間")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", record.averageCallDuration))
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("分")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct PhoneStatRow: View {
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .frame(width: 36, alignment: .leading)

            GeometryReader { geometry in
                let width = maxValue > 0
                    ? geometry.size.width * Double(value) / Double(maxValue)
                    : 0
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.5))
                    .frame(width: max(4, width))
            }
            .frame(height: 16)

            Text("\(value) 回")
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

// MARK: - Message Stats Card

private struct MessageStatsCard: View {
    let record: CommunicationRecord
    let messageScore: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "message.fill")
                    .foregroundStyle(.green)
                Text("メッセージ")
                    .font(.headline)
                Spacer()
                Text("スコア: \(messageScore)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                MessageStatItem(
                    label: "送信",
                    value: "\(record.outgoingMessages)",
                    unit: "通",
                    systemImage: "arrow.up.message.fill",
                    color: .green
                )
                MessageStatItem(
                    label: "受信",
                    value: "\(record.incomingMessages)",
                    unit: "通",
                    systemImage: "arrow.down.message.fill",
                    color: .teal
                )
                MessageStatItem(
                    label: "合計",
                    value: "\(record.totalMessages)",
                    unit: "通",
                    systemImage: "message.badge.fill",
                    color: .mint
                )
                MessageStatItem(
                    label: "送信比率",
                    value: String(format: "%.0f%%", record.outgoingMessageRatio * 100),
                    unit: "",
                    systemImage: "arrow.right.arrow.left",
                    color: .blue
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct MessageStatItem: View {
    let label: String
    let value: String
    let unit: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Contact Diversity Card

private struct ContactDiversityCard: View {
    let record: CommunicationRecord

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Image(systemName: "person.2.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.purple)
                Text("ユニーク連絡先")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(record.uniqueContacts)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("人")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("社会的ネットワークの広さ")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Bidirectional Card

private struct BidirectionalCard: View {
    let record: CommunicationRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("コミュニケーションの双方向性")
                .font(.headline)

            HStack(spacing: 20) {
                // 発信比率
                DirectionGauge(
                    label: "電話",
                    outgoing: record.outgoingCalls,
                    incoming: record.incomingCalls,
                    color: .blue
                )

                DirectionGauge(
                    label: "メッセージ",
                    outgoing: record.outgoingMessages,
                    incoming: record.incomingMessages,
                    color: .green
                )
            }

            Text("発信と受信のバランスが取れているほど、能動的な社会参加を示します。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct DirectionGauge: View {
    let label: String
    let outgoing: Int
    let incoming: Int
    let color: Color

    private var total: Int { outgoing + incoming }
    private var outgoingRatio: Double {
        guard total > 0 else { return 0.5 }
        return Double(outgoing) / Double(total)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            // 双方向バー
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: max(4, geometry.size.width * outgoingRatio))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.3))
                }
            }
            .frame(height: 12)

            HStack {
                Text("発信 \(outgoing)")
                    .font(.caption2)
                Spacer()
                Text("受信 \(incoming)")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
