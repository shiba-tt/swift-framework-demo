import Foundation

/// コーディネート提案
struct Coordinate: Identifiable, Sendable {
    let id = UUID()
    let items: [ClothingItem]
    let overallScore: Double
    let advice: String
    let weatherSummary: String

    var itemsByCategory: [(category: ClothingCategory, items: [ClothingItem])] {
        let grouped = Dictionary(grouping: items) { $0.category }
        return grouped
            .sorted { $0.key.sortOrder < $1.key.sortOrder }
            .map { (category: $0.key, items: $0.value) }
    }

    var scoreLabel: String {
        switch overallScore {
        case 0.8...: return "最適"
        case 0.6...: return "おすすめ"
        case 0.4...: return "まずまず"
        default:     return "要検討"
        }
    }

    var scorePercent: Int {
        Int(overallScore * 100)
    }
}

/// 天気変化アラート
struct WeatherChangeAlert: Identifiable, Sendable {
    let id = UUID()
    let hour: Int
    let message: String
    let suggestion: String
    let systemImage: String

    var hourText: String {
        String(format: "%02d:00", hour)
    }
}
