struct WeatherResponse: Decodable {
    let daily: DailyWeather?
}

struct DailyWeather: Decodable {
    let time: [String?]?
    let temperature: [Double?]?
    let rainProbability: [Double?]?
    let precipitation: [Double?]?
    let windSpeed: [Double?]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m_max"
        case rainProbability = "precipitation_probability_max"
        case precipitation = "precipitation_sum"
        case windSpeed = "wind_speed_10m_max"
    }
}
