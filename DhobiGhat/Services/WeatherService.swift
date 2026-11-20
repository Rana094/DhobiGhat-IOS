import Foundation

struct WeatherService {
    func fetchWeather(for city: City) async throws -> [WeatherDay] {
        let url = try makeURL(for: city)
        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.httpError(httpResponse.statusCode)
        }

        return try decodeWeather(from: data)
    }

    func makeURL(for city: City) throws -> URL {
        guard var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast") else {
            throw WeatherError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(city.latitude)),
            URLQueryItem(name: "longitude", value: String(city.longitude)),
            URLQueryItem(name: "daily", value: "temperature_2m_max,precipitation_probability_max,precipitation_sum,wind_speed_10m_max"),
            URLQueryItem(name: "forecast_days", value: "3"),
            URLQueryItem(name: "timezone", value: "Asia/Dhaka"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "precipitation_unit", value: "mm"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh")
        ]

        guard let url = components.url else {
            throw WeatherError.invalidURL
        }

        return url
    }

    func decodeWeather(from data: Data) throws -> [WeatherDay] {
        let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
        guard let daily = response.daily, let dates = daily.time else { return [] }
        var days: [WeatherDay] = []

        for index in dates.indices.prefix(3) {
            guard let date = dates[index], !date.isEmpty else { continue }

            days.append(WeatherDay(
                date: date,
                temperature: value(at: index, in: daily.temperature),
                rainProbability: value(at: index, in: daily.rainProbability),
                precipitation: value(at: index, in: daily.precipitation),
                windSpeed: value(at: index, in: daily.windSpeed)
            ))
        }

        return days
    }

    private func value(at index: Int, in values: [Double?]?) -> Double? {
        // A missing array, short array, or null element is unavailable, never zero.
        guard let values, values.indices.contains(index) else { return nil }
        return values[index]
    }
}

enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The weather request could not be created. Please try again."
        case .invalidResponse:
            return "The weather server sent an invalid response. Please try again."
        case .httpError(let status):
            return "The weather request failed (HTTP \(status)). Please try again later."
        }
    }
}
