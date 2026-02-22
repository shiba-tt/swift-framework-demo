import Foundation

/// SensorKit 環境光センサーのマネージャー（モック実装）
final class LightSensorManager: Sendable {
    static let shared = LightSensorManager()

    private init() {}

    /// デモ用の 24 時間照度パターンを生成
    /// 正常なパターン: 朝〜日中は高照度、夕方〜夜は低照度
    func generateNormalLightPattern(for date: Date) -> [Double] {
        (0..<24).map { hour in
            switch hour {
            case 0...5:   return Double.random(in: 0...5)
            case 6:       return Double.random(in: 5...30)
            case 7:       return Double.random(in: 50...200)
            case 8...9:   return Double.random(in: 200...800)
            case 10...14: return Double.random(in: 500...2000)
            case 15...16: return Double.random(in: 300...1000)
            case 17:      return Double.random(in: 100...500)
            case 18:      return Double.random(in: 50...200)
            case 19:      return Double.random(in: 20...80)
            case 20...21: return Double.random(in: 10...50)
            case 22...23: return Double.random(in: 2...15)
            default:      return 0
            }
        }
    }

    /// デモ用の 24 時間色温度パターンを生成（ケルビン）
    func generateColorTempPattern() -> [Double] {
        (0..<24).map { hour in
            switch hour {
            case 0...5:   return Double.random(in: 2700...3000)
            case 6...7:   return Double.random(in: 3000...4000)
            case 8...9:   return Double.random(in: 4500...5500)
            case 10...14: return Double.random(in: 5500...6500)
            case 15...16: return Double.random(in: 5000...6000)
            case 17...18: return Double.random(in: 4000...5000)
            case 19...20: return Double.random(in: 3500...4500)
            case 21...22: return Double.random(in: 3000...4000)
            case 23:      return Double.random(in: 2700...3500)
            default:      return 3000
            }
        }
    }

    /// デモ用のリアルタイム照度サンプルを生成
    func generateRealtimeSample() -> LightSample {
        let hour = Calendar.current.component(.hour, from: Date())
        let baseLux: Double
        switch hour {
        case 0...5:   baseLux = Double.random(in: 0...10)
        case 6...8:   baseLux = Double.random(in: 50...300)
        case 9...16:  baseLux = Double.random(in: 300...2000)
        case 17...19: baseLux = Double.random(in: 50...300)
        case 20...23: baseLux = Double.random(in: 5...50)
        default:      baseLux = 100
        }

        return LightSample(
            timestamp: Date(),
            lux: baseLux,
            colorTemperature: Double.random(in: 3000...6500),
            placement: LightSample.LightPlacement.allCases.randomElement() ?? .front
        )
    }

    /// 概日リズムスコアを計算
    func calculateRhythmScore(hourlyLux: [Double]) -> Int {
        guard hourlyLux.count == 24 else { return 50 }

        var score = 100

        // 日中（8-17時）の照度が十分か
        let daytimeSlice = Array(hourlyLux[8...16])
        let daytimeAvg = daytimeSlice.reduce(0, +) / Double(daytimeSlice.count)
        if daytimeAvg < 200 { score -= 15 }

        // 夜間（22-5時）の照度が低いか
        let nightSlice = Array(hourlyLux[22...23]) + Array(hourlyLux[0...5])
        let nightAvg = nightSlice.reduce(0, +) / Double(nightSlice.count)
        if nightAvg > 30 { score -= 20 }

        // 朝の光曝露があるか（起床促進）
        let morningSlice = Array(hourlyLux[6...8])
        let morningAvg = morningSlice.reduce(0, +) / Double(morningSlice.count)
        if morningAvg < 50 { score -= 10 }

        // 日中と夜間のコントラスト
        if daytimeAvg > 0 {
            let contrast = daytimeAvg / max(nightAvg, 1)
            if contrast < 10 { score -= 15 }
        }

        return max(0, min(100, score + Int.random(in: -5...5)))
    }
}
