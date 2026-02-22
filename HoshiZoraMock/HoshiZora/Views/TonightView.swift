import SwiftUI

struct TonightView: View {
    @Bindable var viewModel: HoshiZoraViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("天気データを取得中...")
                } else if let condition = viewModel.tonightCondition {
                    ScrollView {
                        VStack(spacing: 20) {
                            scoreHero(condition)
                            conditionDetailsSection(condition)
                            hourlyTimelineSection()
                            moonInfoSection(condition)
                            adviceSection(condition)
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView("データなし", systemImage: "cloud.fill", description: Text("データを読み込めませんでした"))
                }
            }
            .navigationTitle("Hoshi-Zora")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    // MARK: - Score Hero

    private func scoreHero(_ condition: StargazingCondition) -> some View {
        VStack(spacing: 12) {
            Text("今夜の星空スコア")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: Double(condition.overallScore) / 100.0)
                    .stroke(condition.scoreLevel.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(condition.overallScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                    Text(condition.scoreLevel.displayName)
                        .font(.caption)
                        .foregroundStyle(condition.scoreLevel.color)
                }
            }
            .frame(width: 140, height: 140)

            starsDisplay(condition.scoreLevel.stars)

            Text(condition.scoreLevel.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let bestHour = viewModel.bestHourTonight {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("最適時間帯: \(bestHour.hourText)")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.2), Color(red: 0.1, green: 0.0, blue: 0.3)],
                startPoint: .top, endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func starsDisplay(_ count: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .foregroundStyle(i < count ? .yellow : .white.opacity(0.3))
            }
        }
        .font(.title3)
    }

    // MARK: - Condition Details

    private func conditionDetailsSection(_ condition: StargazingCondition) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("観測条件")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                conditionCard(icon: "cloud.fill", title: "雲量", value: "\(Int(condition.cloudCoverTotal * 100))%", detail: "低層\(Int(condition.cloudCoverLow * 100))% / 中層\(Int(condition.cloudCoverMid * 100))% / 高層\(Int(condition.cloudCoverHigh * 100))%")
                conditionCard(icon: "eye.fill", title: "視程", value: "\(Int(condition.visibility))km", detail: condition.visibilityText)
                conditionCard(icon: "humidity.fill", title: "湿度", value: "\(Int(condition.humidity * 100))%", detail: condition.humidity < 0.5 ? "クリアな空" : "やや霞あり")
                conditionCard(icon: "wind", title: "風速", value: "\(String(format: "%.1f", condition.windSpeed))m/s", detail: condition.windSpeed < 3 ? "穏やか" : condition.windSpeed < 7 ? "やや風あり" : "強風")
                conditionCard(icon: "thermometer.medium", title: "気温", value: condition.temperatureText, detail: condition.temperature < 5 ? "防寒対策を" : "快適")
                conditionCard(icon: "sunset.fill", title: "日没/日出", value: sunTimeText(condition), detail: "観測可能時間帯")
            }
        }
    }

    private func conditionCard(icon: String, title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(detail)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func sunTimeText(_ condition: StargazingCondition) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: condition.sunset))〜\(formatter.string(from: condition.sunrise))"
    }

    // MARK: - Hourly Timeline

    private func hourlyTimelineSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("時間帯別スコア")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.hourlyConditions) { hourly in
                        hourlyBar(hourly)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func hourlyBar(_ hourly: HourlyStarCondition) -> some View {
        VStack(spacing: 4) {
            Text("\(hourly.score)")
                .font(.system(size: 10, weight: .bold))

            RoundedRectangle(cornerRadius: 4)
                .fill(hourly.scoreLevel.color)
                .frame(width: 28, height: CGFloat(hourly.score) * 0.8 + 10)

            Text(hourly.hourText)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Moon Info

    private func moonInfoSection(_ condition: StargazingCondition) -> some View {
        HStack(spacing: 16) {
            Text(condition.moonPhase.emoji)
                .font(.system(size: 48))

            VStack(alignment: .leading, spacing: 4) {
                Text("月齢: \(condition.moonPhase.displayName)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("月明かりの影響: \(Int(condition.moonPhase.lightPollution * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(condition.moonPhase.lightPollution < 0.3 ? "月明かりが少なく好条件" : condition.moonPhase.lightPollution < 0.6 ? "月明かりの影響あり" : "月明かりが強く暗い天体は見づらい")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Advice

    private func adviceSection(_ condition: StargazingCondition) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("観測アドバイス", systemImage: "lightbulb.fill")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                adviceRow(text: "最適観測時間: \(condition.bestTimeRange)")
                if condition.temperature < 5 {
                    adviceRow(text: "気温が低いため、防寒具を忘れずに")
                }
                if condition.humidity > 0.7 {
                    adviceRow(text: "湿度が高め。レンズの曇りに注意")
                }
                if condition.windSpeed > 7 {
                    adviceRow(text: "風が強めです。三脚の固定をしっかりと")
                }
                if condition.moonPhase.lightPollution > 0.5 {
                    adviceRow(text: "月明かりが強いため、月が沈む時間帯がおすすめ")
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
    }

    private func adviceRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.blue)
                .padding(.top, 3)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
