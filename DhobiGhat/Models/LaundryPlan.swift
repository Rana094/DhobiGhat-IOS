import Foundation
import FirebaseFirestore

struct LaundryPlan: Identifiable {
    let id: String
    let city: String
    let date: String
    let note: String
    var isCompleted: Bool
    let createdAt: Timestamp

    init(id: String, data: [String: Any]) throws {
        guard let city = data["city"] as? String,
              let date = data["date"] as? String,
              let note = data["note"] as? String,
              let isCompleted = data["isCompleted"] as? Bool,
              let createdAt = data["createdAt"] as? Timestamp else {
            throw PlanError.invalidData
        }

        guard !id.isEmpty, City.cities.contains(where: { $0.name == city }),
              Self.isValidDate(date) else {
            throw PlanError.invalidData
        }

        self.id = id
        self.city = city
        self.date = date
        self.note = note
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    static func isValidDate(_ value: String) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Dhaka")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false

        guard value.count == 10, let date = formatter.date(from: value) else { return false }
        return formatter.string(from: date) == value
    }
}
