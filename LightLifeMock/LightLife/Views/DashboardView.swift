import SwiftUI

struct DashboardView: View {
    let viewModel: LightLifeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentLightCard
                    rhythmScoreCard
                    lightExposureCard
                    locationLightCard
                    insightsSection
                }
                .padding()
            }
            .navigationTitle("LightLife")
            .refreshable { viewModel.refresh() }
        }
    }

    // MARK: - Components

    private var currentLightCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "light.beacon.max.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Text("現在の光環境")
                    .font(.headline)
                Spacer()
                recordingBadge
            }

            if let sample = viewModel.currentSample {
                HStack(spacing: 24) {
                    VStack {
                        Text("\(Int(sample.lux))")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("lux")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider().frame(height: 50)

                    VStack(alignment: .leading, spacing: 6) {
                        let level = LuxLevel.from(lux: sample.lux)
                        Label(level.rawValue, systemImage: level.icon)
                            .font(.subheadline)
                        Text("色温度: \(Int(sample.colorTemperature))K")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("光源: \(sample.placement.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var recordingBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(viewModel.isRecording ? .red : .gray)
                .frame(width: 8, height: 8)
            Text(viewModel.isRecording ? "記録中" : "停止中")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var rhythmScoreCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.2.circlepath")
                    .font(.title2)
                    .foregroundStyle(.purple)
                Text("概日リズムスコア")
                    .font(.headline)
                Spacer()
            }

            if let profile = viewModel.todayProfile {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(.purple.opacity(0.2), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0, to: Double(profile.rhythmScore) / 100)
                            .stroke(.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        Text("\(profile.rhythmScore)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        let assessment = RhythmAssessment.from(score: profile.rhythmScore)
                        Label(assessment.rawValue, systemImage: assessment.icon)
                            .font(.subheadline.bold())

                        let wakeFormatter = DateFormatter()
                        let _ = wakeFormatter.dateFormat = "H:mm"
                        Text("推定起床: \(wakeFormatter.string(from: profile.estimatedWakeTime))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("推定就寝: \(wakeFormatter.string(from: profile.estimatedSleepTime))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var lightExposureCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sun.and.horizon.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("光曝露サマリー")
                    .font(.headline)
                Spacer()
            }

            if let profile = viewModel.todayProfile {
                HStack(spacing: 16) {
                    exposureItem(
                        title: "日中平均",
                        value: "\(Int(profile.daytimeAverageLux))",
                        unit: "lux",
                        icon: "sun.max.fill",
                        color: .orange
                    )
                    exposureItem(
                        title: "夜間平均",
                        value: "\(Int(profile.nighttimeAverageLux))",
                        unit: "lux",
                        icon: "moon.fill",
                        color: .indigo
                    )
                    exposureItem(
                        title: "ブルーライト",
                        value: profile.blueLightExposureLevel.rawValue,
                        unit: "",
                        icon: profile.blueLightExposureLevel.icon,
                        color: profile.blueLightExposureLevel == .high ? .red : .blue
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func exposureItem(title: String, value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var locationLightCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.title2)
                    .foregroundStyle(.green)
                Text("場所別の光環境")
                    .font(.headline)
                Spacer()
            }

            if let report = viewModel.todayReport {
                ForEach(report.locationSummary.locationBreakdown) { entry in
                    HStack {
                        Image(systemName: entry.category.icon)
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        Text(entry.category.rawValue)
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(entry.duration / 3600))h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(entry.averageLux)) lux")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 70, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var insightsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Text("インサイト")
                    .font(.headline)
                Spacer()
            }

            if let report = viewModel.todayReport {
                ForEach(report.insights) { insight in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: insight.type.icon)
                            .foregroundStyle(insightColor(for: insight.type))
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(.subheadline.bold())
                            Text(insight.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func insightColor(for type: Insight.InsightType) -> Color {
        switch type {
        case .positive: return .green
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
