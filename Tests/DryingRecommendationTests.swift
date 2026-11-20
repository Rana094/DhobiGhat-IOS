import XCTest
@testable import DhobiGhat

// Synthetic rule inputs only; these are not live forecasts.
final class DryingRecommendationTests: XCTestCase {
    @MainActor
    func testProvidedExamples() {
        XCTAssertEqual(recommendation(rain: 10, amount: 0, wind: 12), .good)
        XCTAssertEqual(recommendation(rain: 40, amount: 0, wind: 15), .risky)
        XCTAssertEqual(recommendation(rain: 70, amount: 0, wind: 10), .avoid)
        XCTAssertEqual(recommendation(rain: 10, amount: 5, wind: 10), .avoid)
        XCTAssertEqual(recommendation(rain: 10, amount: 0, wind: 35), .risky)
    }

    @MainActor
    func testRainProbabilityBoundaries() {
        XCTAssertEqual(recommendation(rain: 29.99, amount: 0, wind: 12), .good)
        XCTAssertEqual(recommendation(rain: 30, amount: 0, wind: 12), .risky)
        XCTAssertEqual(recommendation(rain: 59.99, amount: 0, wind: 12), .risky)
        XCTAssertEqual(recommendation(rain: 60, amount: 0, wind: 12), .avoid)
    }

    @MainActor
    func testPrecipitationBoundaries() {
        XCTAssertEqual(recommendation(rain: 10, amount: 0.99, wind: 12), .good)
        XCTAssertEqual(recommendation(rain: 10, amount: 1, wind: 12), .risky)
        XCTAssertEqual(recommendation(rain: 10, amount: 2.99, wind: 12), .risky)
        XCTAssertEqual(recommendation(rain: 10, amount: 3, wind: 12), .avoid)
    }

    @MainActor
    func testWindBoundary() {
        XCTAssertEqual(recommendation(rain: 10, amount: 0, wind: 29.99), .good)
        XCTAssertEqual(recommendation(rain: 10, amount: 0, wind: 30), .risky)
    }

    @MainActor
    func testAvoidTakesPriorityOverRisky() {
        XCTAssertEqual(recommendation(rain: 60, amount: 0, wind: 35), .avoid)
        XCTAssertEqual(recommendation(rain: 40, amount: 3, wind: 35), .avoid)
        XCTAssertEqual(recommendation(rain: 60, amount: 1, wind: 12), .avoid)
    }

    @MainActor
    func testMissingRuleInputsAreUnavailable() {
        XCTAssertNil(recommendation(rain: nil, amount: 0, wind: 12))
        XCTAssertNil(recommendation(rain: 10, amount: nil, wind: 12))
        XCTAssertNil(recommendation(rain: 70, amount: 0, wind: nil))
    }

    @MainActor
    func testInvalidMeasurementsAreUnavailable() {
        XCTAssertNil(recommendation(rain: -1, amount: 0, wind: 12))
        XCTAssertNil(recommendation(rain: 101, amount: 0, wind: 12))
        XCTAssertNil(recommendation(rain: 10, amount: -1, wind: 12))
        XCTAssertNil(recommendation(rain: 10, amount: 0, wind: -1))
        XCTAssertNil(recommendation(rain: Double.nan, amount: 0, wind: 12))
        XCTAssertNil(recommendation(rain: 10, amount: Double.infinity, wind: 12))
        XCTAssertNil(recommendation(rain: 10, amount: 0, wind: Double.infinity))
    }

    @MainActor
    private func recommendation(rain: Double?, amount: Double?, wind: Double?) -> DryingRecommendation? {
        let day = WeatherDay(
            date: "2026-01-01",
            temperature: nil,
            rainProbability: rain,
            precipitation: amount,
            windSpeed: wind
        )
        return day.dryingRecommendation()
    }
}
