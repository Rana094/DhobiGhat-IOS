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
                        .fixedSize(horizontal: false, vertical: true)
                }

                Section("Selected city") {
                    Label(selectedCity, systemImage: "mappin.and.ellipse")
                }

                if let errorMessage = auth.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        auth.logout()
                    } label: {
                        Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .disabled(auth.isLoading)
                }
            }
            .navigationTitle("Profile")
            .scrollContentBackground(.hidden)
            .background(Color.blue.opacity(0.06))
        }
    }
}
