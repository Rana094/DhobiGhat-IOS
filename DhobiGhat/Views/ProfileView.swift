import SwiftUI

struct ProfileView: View {
    let selectedCity: String
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Signed in as") {
                    Text(auth.userEmail)
                        .textSelection(.enabled)
                }

                Section("Selected city") {
                    Text(selectedCity)
                }

                if let errorMessage = auth.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Log out", role: .destructive) {
                        auth.logout()
                    }
                    .disabled(auth.isLoading)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
