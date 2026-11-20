struct WeatherDay: Identifiable, Sendable {
    // Keep the API's Bangladesh calendar date for display and future plan storage.
    let date: String
    let temperature: Double?
    let rainProbability: Double?
    let precipitation: Double?
    let windSpeed: Double?

    var id: String { date }
}
