struct WeatherDay: Identifiable, Sendable {
    // Keep the API's Bangladesh calendar date for display and future plan storage.
    let date: String
    let temperature: Double?
    let rainProbability: Double?
    let precipitation: Double?
    let windSpeed: Double?

    var id: String { date }

    func dryingRecommendation() -> DryingRecommendation? {
        guard let rainProbability, let precipitation, let windSpeed else { return nil }

        if !rainProbability.isFinite || !precipitation.isFinite || !windSpeed.isFinite {
            return nil
        }

        if rainProbability < 0 || rainProbability > 100 || precipitation < 0 || windSpeed < 0 {
            return nil
        }

        if rainProbability >= 60 || precipitation >= 3 {
            return .avoid
        } else if rainProbability >= 30 || precipitation >= 1 || windSpeed >= 30 {
            return .risky
        } else {
            return .good
        }
    }
}

enum DryingRecommendation: String, Sendable {
    case good = "Good"
    case risky = "Risky"
    case avoid = "Avoid"
}
