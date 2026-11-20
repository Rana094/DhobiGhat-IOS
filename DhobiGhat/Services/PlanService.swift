import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
struct PlanService {
    func addPlan(userUID: String, city: String, date: String, note: String) async throws {
        let collection = try plansCollection(userUID: userUID)
        guard City.cities.contains(where: { $0.name == city }) else { throw PlanError.invalidCity }
        guard LaundryPlan.isValidDate(date) else { throw PlanError.invalidDate }

        let data: [String: Any] = [
            "city": city,
            "date": date,
            "note": note,
            "isCompleted": false,
            "createdAt": FieldValue.serverTimestamp()
        ]

        _ = try await collection.addDocument(data: data)
    }

    func fetchPlans(userUID: String) async throws -> [LaundryPlan] {
        let collection = try plansCollection(userUID: userUID)
        let snapshot = try await collection.getDocuments(source: .server)
        var plans: [LaundryPlan] = []

        for document in snapshot.documents {
            let plan = try LaundryPlan(id: document.documentID, data: document.data())
            plans.append(plan)
        }

        return plans.sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
    }

    func completePlan(userUID: String, planID: String) async throws {
        let collection = try plansCollection(userUID: userUID)
        guard !planID.isEmpty, !planID.contains("/") else { throw PlanError.invalidPlan }
        try await collection.document(planID).updateData(["isCompleted": true])
    }

    func deletePlan(userUID: String, planID: String) async throws {
        let collection = try plansCollection(userUID: userUID)
        guard !planID.isEmpty, !planID.contains("/") else { throw PlanError.invalidPlan }
        try await collection.document(planID).delete()
    }

    private func plansCollection(userUID: String) throws -> CollectionReference {
        guard FirebaseApp.app() != nil else { throw PlanError.notConfigured }
        guard !userUID.isEmpty, Auth.auth().currentUser?.uid == userUID else {
            throw PlanError.signedOut
        }

        return Firestore.firestore().collection("users").document(userUID).collection("plans")
    }
}

enum PlanError: LocalizedError {
    case notConfigured
    case signedOut
    case invalidCity
    case invalidDate
    case invalidPlan
    case invalidData

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Firebase is not configured. Complete the README setup and restart the app."
        case .signedOut:
            return "Your signed-in account changed. Sign in again before managing plans."
        case .invalidCity:
            return "Select one of the supported cities."
        case .invalidDate:
            return "Select a valid forecast date in yyyy-MM-dd format."
        case .invalidPlan:
            return "This plan has an invalid identifier. Refresh the list and try again."
        case .invalidData:
            return "A saved plan has missing or invalid fields. Check its fields in Firebase Console."
        }
    }
}
