import Foundation

/// 環境光サンプル — SRAmbientLightSample のモック
struct LightSample: Sendable, Identifiable {
    let id = UUID()
    let timestamp: Date
    /// 照度（ルクス）
    let lux: Double
    /// 色温度（ケルビン）
    let colorTemperature: Double
    /// センサーに対する光源の位置
    let placement: LightPlacement

    enum LightPlacement: String, Sendable, CaseIterable {
        case front = "正面"
        case above = "上方"
        case side = "側面"
        case unknown = "不明"
    }
}

/// 照度レベルの分類
enum LuxLevel: String, Sendable, CaseIterable {
    case dark = "暗闇"
    case dim = "薄暗い"
    case indoor = "室内"
    case bright = "明るい"
    case outdoor = "屋外"
    case directSunlight = "直射日光"

    var range: ClosedRange<Double> {
        switch self {
        case .dark: return 0...10
        case .dim: return 10...50
        case .indoor: return 50...500
        case .bright: return 500...1000
        case .outdoor: return 1000...10000
        case .directSunlight: return 10000...100000
        }
    }

    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .dim: return "moon.haze.fill"
        case .indoor: return "lamp.desk.fill"
        case .bright: return "light.max"
        case .outdoor: return "sun.min.fill"
        case .directSunlight: return "sun.max.fill"
        }
    }

    static func from(lux: Double) -> LuxLevel {
        switch lux {
        case 0..<10: return .dark
        case 10..<50: return .dim
        case 50..<500: return .indoor
        case 500..<1000: return .bright
        case 1000..<10000: return .outdoor
        default: return .directSunlight
        }
    }
}
