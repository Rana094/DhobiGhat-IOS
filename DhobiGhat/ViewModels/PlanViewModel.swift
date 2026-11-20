import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class PlanViewModel: ObservableObject {
    @Published private(set) var plans: [LaundryPlan] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published var errorMessage: String?

    private let service = PlanService()
    private var userUID: String?
    private var accountID = UUID()

    func setUser(_ uid: String?) {
        guard uid != userUID else { return }
        userUID = uid
        accountID = UUID()
        plans = []
        isLoading = false
        isSaving = false
        errorMessage = nil
    }

    func fetchPlans() async {
        guard let uid = userUID, !isLoading, !Task.isCancelled else { return }
        let account = accountID
        isLoading = true
        errorMessage = nil
        defer { finishLoading(account: account) }

        do {
            let fetchedPlans = try await service.fetchPlans(userUID: uid)
            guard isCurrentAccount(uid, account: account), !Task.isCancelled else { return }
            plans = fetchedPlans
        } catch {
            guard isCurrentAccount(uid, account: account), !Task.isCancelled else { return }
            errorMessage = message(for: error)
        }
    }

    func addPlan(city: String, date: String, note: String) async -> Bool {
        guard let uid = userUID, !isLoading else { return false }
        let account = accountID
        isLoading = true
        isSaving = true
        errorMessage = nil
        defer { finishLoading(account: account) }

        do {
            try await service.addPlan(userUID: uid, city: city, date: date, note: note)
        } catch {
            if isCurrentAccount(uid, account: account) {
                errorMessage = message(for: error)
            }
            return false
        }

        guard isCurrentAccount(uid, account: account) else { return false }
        await refreshAfterWrite(uid: uid, account: account, result: "Plan saved")
        return isCurrentAccount(uid, account: account)
    }

    func completePlan(_ plan: LaundryPlan) async {
        guard let uid = userUID, !isLoading, !plan.isCompleted else { return }
        let account = accountID
        isLoading = true
        errorMessage = nil
        defer { finishLoading(account: account) }

        do {
            try await service.completePlan(userUID: uid, planID: plan.id)
        } catch {
            if isCurrentAccount(uid, account: account) {
                errorMessage = message(for: error)
            }
            return
        }

        guard isCurrentAccount(uid, account: account) else { return }
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index].isCompleted = true
        }
        await refreshAfterWrite(uid: uid, account: account, result: "Plan completed")
    }

    func deletePlan(_ plan: LaundryPlan) async {
        guard let uid = userUID, !isLoading else { return }
        let account = accountID
        isLoading = true
        errorMessage = nil
        defer { finishLoading(account: account) }

        do {
            try await service.deletePlan(userUID: uid, planID: plan.id)
        } catch {
            if isCurrentAccount(uid, account: account) {
                errorMessage = message(for: error)
            }
            return
        }

        guard isCurrentAccount(uid, account: account) else { return }
        plans.removeAll { $0.id == plan.id }
        await refreshAfterWrite(uid: uid, account: account, result: "Plan deleted")
    }

    private func refreshAfterWrite(uid: String, account: UUID, result: String) async {
        do {
            let fetchedPlans = try await service.fetchPlans(userUID: uid)
            guard isCurrentAccount(uid, account: account) else { return }
            plans = fetchedPlans
        } catch {
            guard isCurrentAccount(uid, account: account) else { return }
            // The write succeeded. Do not invite a duplicate Save just because refresh failed.
            errorMessage = "\(result), but the list could not refresh. \(message(for: error))"
        }
    }

    private func isCurrentAccount(_ uid: String, account: UUID) -> Bool {
        guard FirebaseApp.app() != nil else { return false }
        return accountID == account && userUID == uid && Auth.auth().currentUser?.uid == uid
    }

    private func finishLoading(account: UUID) {
        if accountID == account {
            isLoading = false
            isSaving = false
        }
    }

    private func message(for error: Error) -> String {
        if let planError = error as? PlanError {
            return planError.localizedDescription
        }

        let code = FirestoreErrorCode.Code(rawValue: (error as NSError).code)
        switch code {
        case .permissionDenied:
            return "Permission denied. Check the signed-in account and publish firestore.rules for this Firebase project."
        case .unavailable, .deadlineExceeded:
            return "Firestore is unavailable. Check your internet connection and try refreshing again."
        case .unauthenticated:
            return "Your session is no longer authorized. Log out and sign in again."
        case .notFound:
            return "This plan no longer exists. Refresh the list."
        case .failedPrecondition:
            return "Firestore could not process this request. Check database setup in Firebase Console."
        default:
            return "Firestore request failed: \(error.localizedDescription)"
        }
    }
}
