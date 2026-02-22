import SwiftUI

/// リズム改善アドバイス画面
struct AdviceView: View {
    let viewModel: ChronoSenseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let profile = viewModel.displayProfile {
                        // スコアサマリー
                        ScoreBanner(profile: profile)

                        // アドバイスリスト
                        if viewModel.todayAdvice.isEmpty {
                            ContentUnavailableView(
                                "問題ありません",
                                systemImage: "checkmark.seal.fill",
                                description: Text("現在のリズムは良好です。この調子を維持しましょう。")
                            )
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.todayAdvice.sorted(by: { $0.priority > $1.priority })) { advice in
                                    AdviceCard(advice: advice)
                                }
                            }
                        }

                        // 概日リズムの知識
                        CircadianInfoSection()
                    } else {
                        ProgressView("読み込み中...")
                    }
                }
                .padding()
            }
            .navigationTitle("アドバイス")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Score Banner

private struct ScoreBanner: View {
    let profile: CircadianProfile

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: Double(profile.rhythmScore) / 100.0)
                    .stroke(
                        Color(profile.scoreLevel.colorName),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(profile.rhythmScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    Text("点")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text("今日のリズム: \(profile.scoreLevel.rawValue)")
                    .font(.headline)
                Text("活動ピーク \(profile.peakActivityHour):00 / 光ピーク \(profile.peakLightHour):00")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("総歩数: \(profile.totalSteps)歩")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Advice Card

private struct AdviceCard: View {
    let advice: RhythmAdvice

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: advice.category.systemImageName)
                .font(.title2)
                .foregroundStyle(Color(advice.category.colorName))
                .frame(width: 40, height: 40)
                .background(Color(advice.category.colorName).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(advice.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    PriorityBadge(priority: advice.priority)
                }
                Text(advice.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct PriorityBadge: View {
    let priority: RhythmAdvice.AdvicePriority

    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var label: String {
        switch priority {
        case .high: "重要"
        case .medium: "推奨"
        case .low: "参考"
        }
    }

    private var color: Color {
        switch priority {
        case .high: .red
        case .medium: .orange
        case .low: .blue
        }
    }
}

// MARK: - Circadian Info Section

private struct CircadianInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("概日リズムについて")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    icon: "sun.max.fill",
                    color: .yellow,
                    text: "朝の光を浴びることで体内時計がリセットされます"
                )
                InfoRow(
                    icon: "moon.fill",
                    color: .purple,
                    text: "就寝前のブルーライトはメラトニン分泌を抑制します"
                )
                InfoRow(
                    icon: "figure.walk",
                    color: .green,
                    text: "日中の適度な運動が夜の睡眠の質を高めます"
                )
                InfoRow(
                    icon: "clock.fill",
                    color: .indigo,
                    text: "規則正しい生活リズムが概日リズムを安定させます"
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct InfoRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
