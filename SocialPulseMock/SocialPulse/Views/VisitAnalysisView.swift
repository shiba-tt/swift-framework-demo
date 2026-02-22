import SwiftUI

/// 訪問分析画面 — 外出パターンと行動範囲の分析
struct VisitAnalysisView: View {
    let viewModel: SocialPulseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if let visit = viewModel.todayVisitRecord, let score = viewModel.currentScore {
                    VStack(spacing: 20) {
                        // 行動範囲レベル
                        MobilityLevelCard(visit: visit, visitScore: score.visitScore)

                        // 訪問サマリー
                        VisitSummaryCards(visit: visit)

                        // カテゴリ別内訳
                        CategoryBreakdownCard(visit: visit)

                        // 移動距離
                        DistanceCard(visit: visit)

                        // 行動パターンの説明
                        MobilityInfoSection()
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "データなし",
                        systemImage: "mappin.slash",
                        description: Text("訪問データがまだ収集されていません")
                    )
                }
            }
            .navigationTitle("訪問分析")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Mobility Level Card

private struct MobilityLevelCard: View {
    let visit: VisitRecord
    let visitScore: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: visit.mobilityLevel.systemImageName)
                .font(.largeTitle)
                .foregroundStyle(Color(visit.mobilityLevel.colorName))
                .frame(width: 60, height: 60)
                .background(Color(visit.mobilityLevel.colorName).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("今日の行動範囲")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(visit.mobilityLevel.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(visit.mobilityLevel.colorName))
                Text("訪問スコア: \(visitScore) / 100")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Visit Summary Cards

private struct VisitSummaryCards: View {
    let visit: VisitRecord

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 12) {
            VisitStatCard(
                title: "訪問場所数",
                value: "\(visit.placesVisited)",
                unit: "箇所",
                systemImage: "mappin.circle.fill",
                color: .orange
            )
            VisitStatCard(
                title: "自宅外時間",
                value: String(format: "%.1f", visit.timeOutsideHours),
                unit: "時間",
                systemImage: "clock.fill",
                color: .blue
            )
            VisitStatCard(
                title: "移動距離",
                value: String(format: "%.1f", visit.distanceFromHomeKm),
                unit: "km",
                systemImage: "location.fill",
                color: .green
            )
            VisitStatCard(
                title: "カテゴリ多様性",
                value: String(format: "%.0f%%", visit.categoryDiversity * 100),
                unit: "",
                systemImage: "square.grid.3x3.fill",
                color: .purple
            )
        }
    }
}

private struct VisitStatCard: View {
    let title: String
    let value: String
    let unit: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Category Breakdown Card

private struct CategoryBreakdownCard: View {
    let visit: VisitRecord

    private var sortedCategories: [(VisitCategory, Int)] {
        visit.categories
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
    }

    private var totalVisits: Int {
        visit.categories.values.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.orange)
                Text("訪問カテゴリ内訳")
                    .font(.headline)
            }

            if sortedCategories.isEmpty {
                Text("今日のカテゴリデータはありません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(sortedCategories, id: \.0) { category, count in
                    CategoryRow(
                        category: category,
                        count: count,
                        totalVisits: totalVisits
                    )
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct CategoryRow: View {
    let category: VisitCategory
    let count: Int
    let totalVisits: Int

    private var ratio: Double {
        guard totalVisits > 0 else { return 0 }
        return Double(count) / Double(totalVisits)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.systemImageName)
                .font(.body)
                .foregroundStyle(Color(category.colorName))
                .frame(width: 28, height: 28)
                .background(Color(category.colorName).opacity(0.15))
                .clipShape(Circle())

            Text(category.rawValue)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(category.colorName).opacity(0.5))
                    .frame(width: max(4, geometry.size.width * ratio))
            }
            .frame(height: 14)

            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .frame(width: 24, alignment: .trailing)
        }
    }
}

// MARK: - Distance Card

private struct DistanceCard: View {
    let visit: VisitRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundStyle(.green)
                Text("自宅からの最大距離")
                    .font(.headline)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", visit.distanceFromHomeKm))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                        Text("km")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Text("GPS座標は取得されません（プライバシー保護設計）")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // 距離レベル表示
            DistanceLevelIndicator(distance: visit.distanceFromHomeKm)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct DistanceLevelIndicator: View {
    let distance: Double

    private var level: String {
        switch distance {
        case 10...: "広範囲"
        case 5..<10: "中距離"
        case 1..<5: "近距離"
        default: "自宅周辺"
        }
    }

    private var color: Color {
        switch distance {
        case 10...: .green
        case 5..<10: .blue
        case 1..<5: .orange
        default: .red
        }
    }

    var body: some View {
        HStack {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(index < barCount ? color : Color(.systemGray5))
                    .frame(height: 6)
            }

            Text(level)
                .font(.caption)
                .foregroundStyle(color)
                .fontWeight(.medium)
        }
    }

    private var barCount: Int {
        switch distance {
        case 10...: 4
        case 5..<10: 3
        case 1..<5: 2
        default: 1
        }
    }
}

// MARK: - Mobility Info Section

private struct MobilityInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("訪問データについて")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    icon: "shield.checkmark.fill",
                    color: .green,
                    text: "SensorKit の訪問データはGPS座標を含みません。プライバシーが保護されています。"
                )
                InfoRow(
                    icon: "mappin.and.ellipse",
                    color: .orange,
                    text: "訪問場所はカテゴリ（自宅/職場/ジム等）と自宅からの距離のみで記録されます。"
                )
                InfoRow(
                    icon: "figure.walk",
                    color: .blue,
                    text: "外出頻度と行動範囲は社会的孤立の早期検出に重要な指標です。"
                )
                InfoRow(
                    icon: "brain.head.profile",
                    color: .purple,
                    text: "行動範囲の狭小化はうつ病や認知症のリスク因子として研究されています。"
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
