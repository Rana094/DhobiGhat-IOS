import Foundation
import Combine
import FirebaseCore
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var userEmail = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var isCheckingSession = true
    @Published private(set) var setupError: String?

    private var auth: Auth?
    private var authListener: NSObjectProtocol?

    // RootView calls this after launch, not during ViewModel creation.
    func startListening() {
        guard authListener == nil else { return }

        guard FirebaseApp.app() != nil else {
            setupError = "Add the real GoogleService-Info.plist to the DhobiGhat target, check its bundle ID, then restart the app. See README for setup steps."
            isCheckingSession = false
            return
        }

        setupError = nil
        isCheckingSession = true
        let firebaseAuth = Auth.auth()
        auth = firebaseAuth

        authListener = firebaseAuth.addStateDidChangeListener { [weak self] _, _ in
            Task { @MainActor [weak self] in
                guard let self, let auth = self.auth else { return }
                // Read Firebase's latest session instead of keeping a separate login flag.
                self.currentUser = auth.currentUser
                self.userEmail = auth.currentUser?.email ?? ""
                self.isCheckingSession = false
            }
        }
    }

    func stopListening() {
        if let auth, let authListener {
            auth.removeStateDidChangeListener(authListener)
        }

        authListener = nil
        auth = nil
        currentUser = nil
        userEmail = ""
        isCheckingSession = true
    }

    func register(email: String, password: String) async {
        guard !isLoading else { return }
        errorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validate(email: cleanEmail, password: password, isRegistering: true) else { return }
        guard let auth else {
            errorMessage = "Firebase is not ready. Complete setup and restart the app."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await auth.createUser(withEmail: cleanEmail, password: password)
        } catch {
            errorMessage = message(for: error)
        }
    }

    func login(email: String, password: String) async {
        guard !isLoading else { return }
        errorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validate(email: cleanEmail, password: password, isRegistering: false) else { return }
        guard let auth else {
            errorMessage = "Firebase is not ready. Complete setup and restart the app."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await auth.signIn(withEmail: cleanEmail, password: password)
        } catch {
            errorMessage = message(for: error)
        }
    }

    func logout() {
        guard !isLoading else { return }
        errorMessage = nil
        guard let auth else {
            errorMessage = "Firebase is not ready. Complete setup and restart the app."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try auth.signOut()
            currentUser = nil
            userEmail = ""
        } catch {
            errorMessage = message(for: error)
        }
    }

    private func validate(email: String, password: String, isRegistering: Bool) -> Bool {
        if email.isEmpty {
            errorMessage = "Enter your email address."
            return false
        }

        // Basic format check; Firebase performs the final validation.
        if email.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) == nil {
            errorMessage = "Enter a valid email address, such as name@example.com."
            return false
        }

        if password.isEmpty {
            errorMessage = "Enter your password."
            return false
        }

        if isRegistering && password.count < 6 {
            errorMessage = "Use at least 6 characters for your password."
            return false
        }

        return true
    }

    private func message(for error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)

        switch code {
        case .invalidEmail:
            return "Enter a valid email address."
        case .wrongPassword, .userNotFound, .invalidCredential:
            return "The email or password is incorrect. Check both and try again."
        case .emailAlreadyInUse:
            return "An account already uses this email. Try logging in."
        case .weakPassword:
            return "Choose a stronger password that meets your Firebase project's password policy."
        case .userDisabled:
            return "This account has been disabled. Contact the project owner."
        case .networkError:
            return "Could not connect to Firebase. Check your internet connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Wait a little and try again."
        case .operationNotAllowed:
            return "Email/password sign-in is not enabled. Enable it in Firebase Console."
        case .invalidAPIKey, .appNotAuthorized:
            return "Firebase configuration is invalid for this app. Check the plist and bundle ID."
        case .keychainError:
            return "The device could not update the secure sign-in session. Restart the app and try again."
        default:
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
}
