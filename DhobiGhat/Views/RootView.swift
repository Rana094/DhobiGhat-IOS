import SwiftUI

struct RootView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        ZStack {
            if let setupError = auth.setupError {
                ContentUnavailableView(
                    "Firebase setup needed",
                    systemImage: "gearshape",
                    description: Text(setupError)
                )
            } else if auth.isCheckingSession {
                ProgressView("Checking your session…")
            } else if let user = auth.currentUser {
                MainTabView()
                    .id(user.uid)
            } else {
                LoginView()
            }
        }
        .environmentObject(auth)
        .task {
            auth.startListening()
        }
        .onDisappear {
            auth.stopListening()
        }
    }
}
