import Foundation

/// WeatherKit データを基にコーディネートを提案するエンジン
/// 実デバイスでは WeatherService.shared.weather(for:) を使用
@MainActor
@Observable
final class CoordinateEngine {
    static let shared = CoordinateEngine()
    private init() {}

    // MARK: - State

    private(set) var currentWeather: WeatherSnapshot = .sampleSpring
    private(set) var hourlyForecast: [HourlyWeather] = []
    private(set) var coordinate: Coordinate?
    private(set) var weatherAlerts: [WeatherChangeAlert] = []
    private(set) var isLoading = false
    private(set) var lastUpdated: Date?
    private(set) var locationName: String = "東京都"

    // MARK: - Fetch

    func fetchWeatherAndSuggest() async {
        isLoading = true

        // モック: WeatherKit API コールをシミュレーション
        try? await Task.sleep(for: .seconds(1))

        // ランダムにサンプルデータを選択
        let samples: [WeatherSnapshot] = [.sampleSpring, .sampleSummer, .sampleRainy, .sampleWinter]
        currentWeather = samples.randomElement()!

        hourlyForecast = HourlyWeather.generateMockForecast(base: currentWeather)
        coordinate = buildCoordinate()
        weatherAlerts = detectWeatherChanges()
        lastUpdated = Date()
        isLoading = false
    }

    // MARK: - Coordination Logic

    /// 天気に最適なコーディネートを構築
    private func buildCoordinate() -> Coordinate {
        let allItems = ClothingItem.allItems

        // カテゴリごとに最適なアイテムを選択
        var selected: [ClothingItem] = []

        for category in ClothingCategory.allCases {
            let candidates = allItems.filter { $0.category == category }
            let sorted = candidates.sorted { $0.suitability(for: currentWeather) > $1.suitability(for: currentWeather) }

            if category == .accessory {
                // アクセサリーは条件に合うもの全て（スコア0.5以上）
                let suitable = sorted.filter { $0.suitability(for: currentWeather) > 0.5 }
                selected.append(contentsOf: suitable.prefix(2))
            } else if category == .outer {
                // アウターは気温が20度以下か雨の場合のみ
                if currentWeather.temperature < 20 || currentWeather.precipitationChance > 0.5 {
                    if let best = sorted.first {
                        selected.append(best)
                    }
                }
            } else {
                // その他は最適なもの1つ
                if let best = sorted.first {
                    selected.append(best)
                }
            }
        }

        let avgScore = selected.isEmpty ? 0.0 : selected.map { $0.suitability(for: currentWeather) }.reduce(0, +) / Double(selected.count)

        return Coordinate(
            items: selected,
            overallScore: avgScore,
            advice: generateAdvice(),
            weatherSummary: generateWeatherSummary()
        )
    }

    /// 天気に応じたアドバイスを生成
    private func generateAdvice() -> String {
        var parts: [String] = []

        // 気温アドバイス
        if currentWeather.temperature >= 30 {
            parts.append("猛暑日です。通気性の良い素材で涼しく過ごしましょう")
        } else if currentWeather.temperature >= 25 {
            parts.append("暑い一日になりそうです。軽装で")
        } else if currentWeather.temperature <= 5 {
            parts.append("とても寒い日です。暖かい服装を心がけましょう")
        } else if currentWeather.temperature <= 15 {
            parts.append("やや肌寒い気温です。重ね着がおすすめ")
        }

        // 雨アドバイス
        if currentWeather.precipitationChance > 0.7 {
            parts.append("降水確率が高いため、防水アイテムを忘れずに")
        } else if currentWeather.precipitationChance > 0.4 {
            parts.append("念のため折りたたみ傘を持っておくと安心です")
        }

        // UV アドバイス
        if currentWeather.uvIndex >= 6 {
            parts.append("紫外線が強いため、UV対策を万全に")
        }

        // 風アドバイス
        if currentWeather.windSpeed > 7 {
            parts.append("風が強いため、軽いアイテムは飛ばされないよう注意")
        }

        // 温度差アドバイス
        let tempRange = hourlyForecast.map(\.temperature)
        if let maxT = tempRange.max(), let minT = tempRange.min(), maxT - minT > 8 {
            parts.append("日中の気温差が大きいため、脱ぎ着しやすい服装がベスト")
        }

        if parts.isEmpty {
            parts.append("過ごしやすい天気です。お好みのスタイルでどうぞ")
        }

        return parts.joined(separator: "。") + "。"
    }

    /// 天気サマリーを生成
    private func generateWeatherSummary() -> String {
        let tempRange = hourlyForecast.map(\.temperature)
        let minT = tempRange.min() ?? currentWeather.temperature
        let maxT = tempRange.max() ?? currentWeather.temperature

        return "\(currentWeather.condition.emoji) \(currentWeather.condition.rawValue) \(String(format: "%.0f", minT))〜\(String(format: "%.0f°C", maxT)) / 降水 \(currentWeather.precipitationChanceText)"
    }

    // MARK: - Weather Change Detection

    /// 時間帯ごとの天気変化を検出（iOS 18 WeatherChanges 相当）
    private func detectWeatherChanges() -> [WeatherChangeAlert] {
        var alerts: [WeatherChangeAlert] = []

        for i in 1..<hourlyForecast.count {
            let prev = hourlyForecast[i - 1]
            let curr = hourlyForecast[i]

            // 急な気温低下
            if prev.temperature - curr.temperature > 3 {
                alerts.append(WeatherChangeAlert(
                    hour: curr.hour,
                    message: "\(curr.hourText) 頃から気温が急低下",
                    suggestion: "上着を準備しましょう",
                    systemImage: "thermometer.snowflake"
                ))
            }

            // 雨の降り始め
            if prev.precipitationChance < 0.3 && curr.precipitationChance > 0.6 {
                alerts.append(WeatherChangeAlert(
                    hour: curr.hour,
                    message: "\(curr.hourText) 頃から雨の可能性",
                    suggestion: "傘を忘れずに",
                    systemImage: "cloud.rain.fill"
                ))
            }

            // UV 急上昇
            if prev.uvIndex <= 3 && curr.uvIndex >= 6 {
                alerts.append(WeatherChangeAlert(
                    hour: curr.hour,
                    message: "\(curr.hourText) 頃から紫外線が強まります",
                    suggestion: "サングラス・帽子を準備",
                    systemImage: "sun.max.trianglebadge.exclamationmark.fill"
                ))
            }
        }

        return alerts
    }
}
