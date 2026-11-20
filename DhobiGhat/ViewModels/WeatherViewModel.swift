import Foundation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published private(set) var days: [WeatherDay] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var cityName = ""

    private let service = WeatherService()
    private var requestID = UUID()

    func loadWeather(for city: City) async {
        guard !Task.isCancelled else { return }
        let currentRequest = UUID()
        requestID = currentRequest
        cityName = city.name
        days = []
        errorMessage = nil
        isLoading = true

        defer {
            if requestID == currentRequest {
                isLoading = false
            }
        }

        do {
            let forecast = try await service.fetchWeather(for: city)
            try Task.checkCancellation()
            guard requestID == currentRequest else { return }
            days = forecast
        } catch is CancellationError {
            // A city change or leaving the screen cancels the old request normally.
        } catch let error as URLError where error.code == .cancelled {
            // URLSession can report the same cancellation as a URLError.
        } catch {
            guard requestID == currentRequest, !Task.isCancelled else { return }
            errorMessage = message(for: error)
        }
    }

    private func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                return "No internet connection. Connect and tap Retry."
            } else if urlError.code == .timedOut {
                return "The weather request timed out. Please try again."
            } else {
                return "Could not reach the weather service. Check your connection and try again."
            }
        } else if error is DecodingError {
            return "The weather data could not be read. Please try again later."
        } else {
            return error.localizedDescription
        }
    }
}
