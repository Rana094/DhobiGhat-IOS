import Foundation
import XCTest
@testable import DhobiGhat

// Synthetic JSON fixtures for parser tests only. The app never uses these values.
final class WeatherServiceTests: XCTestCase {
    @MainActor
    func testRequestContainsCityAndRequiredParameters() throws {
        for city in City.cities {
            let url = try WeatherService().makeURL(for: city)
            let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
            var parameters: [String: String] = [:]

            for item in components.queryItems ?? [] {
                parameters[item.name] = item.value
            }

            XCTAssertEqual(components.scheme, "https")
            XCTAssertEqual(components.host, "api.open-meteo.com")
            XCTAssertEqual(components.path, "/v1/forecast")
            XCTAssertEqual(parameters["latitude"], String(city.latitude))
            XCTAssertEqual(parameters["longitude"], String(city.longitude))
            XCTAssertEqual(parameters["daily"], "temperature_2m_max,precipitation_probability_max,precipitation_sum,wind_speed_10m_max")
            XCTAssertEqual(parameters["forecast_days"], "3")
            XCTAssertEqual(parameters["timezone"], "Asia/Dhaka")
            XCTAssertEqual(parameters["wind_speed_unit"], "kmh")
            XCTAssertEqual(parameters["temperature_unit"], "celsius")
            XCTAssertEqual(parameters["precipitation_unit"], "mm")
        }
    }

    @MainActor
    func testCompleteForecastDecodesAllMeasurements() throws {
        let json = #"""
        {"daily": {
            "time": ["2026-01-01", "2026-01-02", "2026-01-03"],
            "temperature_2m_max": [28.5, 29, 30],
            "precipitation_probability_max": [10, 40, 75],
            "precipitation_sum": [0, 1.2, 5],
            "wind_speed_10m_max": [12, 15, 31]
        }}
        """#
        let days = try WeatherService().decodeWeather(from: Data(json.utf8))
        XCTAssertEqual(days.count, 3)
        let first = try XCTUnwrap(days.first)
        XCTAssertEqual(first.date, "2026-01-01")
        XCTAssertEqual(first.temperature, 28.5)
        XCTAssertEqual(first.rainProbability, 10)
        XCTAssertEqual(first.precipitation, 0)
        XCTAssertEqual(first.windSpeed, 12)
        XCTAssertEqual(days.last?.windSpeed, 31)
    }

    @MainActor
    func testMissingNullAndShortArraysPreserveDateAlignment() throws {
        let json = #"""
        {"daily": {
            "time": ["2026-01-01", "2026-01-02", "2026-01-03"],
            "temperature_2m_max": [28.5, null],
            "precipitation_probability_max": null,
            "wind_speed_10m_max": [12]
        }}
        """#
        let days = try WeatherService().decodeWeather(from: Data(json.utf8))
        XCTAssertEqual(days.count, 3)
        guard days.count == 3 else { return }
        XCTAssertEqual(days[0].temperature, 28.5)
        XCTAssertNil(days[1].temperature)
        XCTAssertNil(days[2].temperature)
        XCTAssertEqual(days[0].windSpeed, 12)
        XCTAssertNil(days[1].windSpeed)
        XCTAssertNil(days[2].windSpeed)

        for day in days {
            XCTAssertNil(day.rainProbability)
            XCTAssertNil(day.precipitation)
        }
    }

    @MainActor
    func testMissingDailyOrDatesReturnsNoDays() throws {
        let fixtures = [#"{}"#, #"{"daily":null}"#, #"{"daily":{}}"#, #"{"daily":{"time":null}}"#]

        for json in fixtures {
            let days = try WeatherService().decodeWeather(from: Data(json.utf8))
            XCTAssertTrue(days.isEmpty)
        }
    }

    @MainActor
    func testUnavailableDatesDoNotShiftMeasurements() throws {
        let json = #"""
        {"daily": {
            "time": [null, "2026-01-02", ""],
            "temperature_2m_max": [10, 22, 30]
        }}
        """#
        let days = try WeatherService().decodeWeather(from: Data(json.utf8))
        XCTAssertEqual(days.count, 1)
        XCTAssertEqual(days.first?.date, "2026-01-02")
        XCTAssertEqual(days.first?.temperature, 22)
    }

    @MainActor
    func testMoreThanThreeDatesIsLimitedToThreeDays() throws {
        let json = #"""
        {"daily":{"time":["2026-01-01","2026-01-02","2026-01-03","2026-01-04"]}}
        """#
        let days = try WeatherService().decodeWeather(from: Data(json.utf8))
        XCTAssertEqual(days.count, 3)
        XCTAssertEqual(days.last?.date, "2026-01-03")
        XCTAssertNil(days.first?.temperature)
    }

    @MainActor
    func testMalformedJSONAndWrongTypesThrow() {
        let invalidJSON = Data("not JSON".utf8)
        let wrongType = Data(#"{"daily":{"time":["2026-01-01"],"temperature_2m_max":["warm"]}}"#.utf8)
        XCTAssertThrowsError(try WeatherService().decodeWeather(from: invalidJSON))
        XCTAssertThrowsError(try WeatherService().decodeWeather(from: wrongType))
    }
}
