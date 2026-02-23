import Foundation

/// 環境音ログのエントリ
struct SoundLogEntry: Identifiable, Sendable {
    let id: UUID
    let category: SoundCategory
    let startTime: Date
    let duration: TimeInterval
    let averageDecibel: Double
    let peakDecibel: Double
    let locationName: String?

    init(
        id: UUID = UUID(),
        category: SoundCategory,
        startTime: Date,
        duration: TimeInterval,
        averageDecibel: Double,
        peakDecibel: Double,
        locationName: String? = nil
    ) {
        self.id = id
        self.category = category
        self.startTime = startTime
        self.duration = duration
        self.averageDecibel = averageDecibel
        self.peakDecibel = peakDecibel
        self.locationName = locationName
    }

    var durationText: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)分\(seconds)秒"
        }
        return "\(seconds)秒"
    }

    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    var decibelText: String {
        String(format: "%.0f dB", averageDecibel)
    }

    // MARK: - Sample Data

    static let samples: [SoundLogEntry] = {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        return [
            SoundLogEntry(
                category: .bird,
                startTime: calendar.date(bySettingHour: 6, minute: 15, second: 0, of: today)!,
                duration: 900,
                averageDecibel: 42,
                peakDecibel: 58,
                locationName: "自宅ベランダ"
            ),
            SoundLogEntry(
                category: .car,
                startTime: calendar.date(bySettingHour: 7, minute: 30, second: 0, of: today)!,
                duration: 1200,
                averageDecibel: 68,
                peakDecibel: 82,
                locationName: "国道沿い"
            ),
            SoundLogEntry(
                category: .keyboard,
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!,
                duration: 7200,
                averageDecibel: 45,
                peakDecibel: 52,
                locationName: "オフィス"
            ),
            SoundLogEntry(
                category: .voice,
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                duration: 2700,
                averageDecibel: 62,
                peakDecibel: 75,
                locationName: "社食"
            ),
            SoundLogEntry(
                category: .music,
                startTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: today)!,
                duration: 1800,
                averageDecibel: 55,
                peakDecibel: 70,
                locationName: "オフィス"
            ),
            SoundLogEntry(
                category: .rain,
                startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!,
                duration: 3600,
                averageDecibel: 50,
                peakDecibel: 65,
                locationName: nil
            ),
            SoundLogEntry(
                category: .siren,
                startTime: calendar.date(bySettingHour: 16, minute: 45, second: 0, of: today)!,
                duration: 30,
                averageDecibel: 85,
                peakDecibel: 95,
                locationName: "オフィス前"
            ),
            SoundLogEntry(
                category: .dog,
                startTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!,
                duration: 600,
                averageDecibel: 55,
                peakDecibel: 72,
                locationName: "公園"
            ),
        ]
    }()
}
