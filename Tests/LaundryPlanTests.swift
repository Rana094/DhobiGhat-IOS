import XCTest
import FirebaseFirestore
@testable import DhobiGhat

// Synthetic dictionary fixtures. These tests do not contact Firebase.
final class LaundryPlanTests: XCTestCase {
    @MainActor
    private func validData() -> [String: Any] {
        [
            "city": "Khulna",
            "date": "2026-11-20",
            "note": "Towels",
            "isCompleted": false,
            "createdAt": Timestamp(seconds: 1_700_000_000, nanoseconds: 0)
        ]
    }

    @MainActor
    func testMapsAllFirestoreFields() throws {
        let plan = try LaundryPlan(id: "test-plan", data: validData())
        XCTAssertEqual(plan.id, "test-plan")
        XCTAssertEqual(plan.city, "Khulna")
        XCTAssertEqual(plan.date, "2026-11-20")
        XCTAssertEqual(plan.note, "Towels")
        XCTAssertFalse(plan.isCompleted)
        XCTAssertEqual(plan.createdAt.seconds, 1_700_000_000)
    }

    @MainActor
    func testEmptyNoteAndCompletedStatusArePreserved() throws {
        var data = validData()
        data["note"] = ""
        data["isCompleted"] = true
        let plan = try LaundryPlan(id: "completed-plan", data: data)
        XCTAssertEqual(plan.note, "")
        XCTAssertTrue(plan.isCompleted)
    }

    @MainActor
    func testMissingRequiredFieldsThrowInsteadOfInventingDefaults() {
        for key in ["city", "date", "note", "isCompleted", "createdAt"] {
            var data = validData()
            data.removeValue(forKey: key)
            XCTAssertThrowsError(try LaundryPlan(id: "test-plan", data: data), key)
        }
    }

    @MainActor
    func testWrongFieldTypesThrow() {
        let invalidValues: [String: Any] = [
            "city": 10,
            "date": 20261120,
            "note": false,
            "isCompleted": "false",
            "createdAt": "2026-11-20"
        ]

        for (key, value) in invalidValues {
            var data = validData()
            data[key] = value
            XCTAssertThrowsError(try LaundryPlan(id: "test-plan", data: data), key)
        }
    }

    @MainActor
    func testDateValidationUsesStrictCalendarDates() {
        XCTAssertTrue(LaundryPlan.isValidDate("2024-02-29"))
        XCTAssertTrue(LaundryPlan.isValidDate("2026-11-20"))

        for date in ["2026-02-29", "2026-02-30", "2026-13-01", "2026-1-02", "20-11-2026", "2026-11-20T00:00:00Z", ""] {
            XCTAssertFalse(LaundryPlan.isValidDate(date), date)
        }
    }

    @MainActor
    func testUnsupportedCityAndEmptyIDAreRejected() {
        var data = validData()
        data["city"] = "Unsupported city"
        XCTAssertThrowsError(try LaundryPlan(id: "test-plan", data: data))
        XCTAssertThrowsError(try LaundryPlan(id: "", data: validData()))
    }

    @MainActor
    func testInvalidStoredDateIsRejected() {
        var data = validData()
        data["date"] = "2026-02-30"
        XCTAssertThrowsError(try LaundryPlan(id: "test-plan", data: data))
    }
}
