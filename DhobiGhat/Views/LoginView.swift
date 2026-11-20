import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "drop.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                            .accessibilityHidden(true)

                        Text("Smart Laundry Day Planner")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Sign in to plan your laundry days.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Account details") {
                    TextField("Email address", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                        .textContentType(isRegistering ? .newPassword : .password)

                    if isRegistering {
                        Text("Use at least 6 characters for your password.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if let errorMessage = auth.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            if isRegistering {
                                await auth.register(email: email, password: password)
                            } else {
                                await auth.login(email: email, password: password)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if auth.isLoading {
                                ProgressView()
                            }
                            Text(isRegistering ? "Create account" : "Log in")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }

                    Button {
                        isRegistering.toggle()
                        password = ""
                        auth.errorMessage = nil
                    } label: {
                        Text(isRegistering ? "Already have an account? Log in" : "New here? Create an account")
                    }
                }
            }
            .disabled(auth.isLoading)
            .scrollContentBackground(.hidden)
            .background(Color.blue.opacity(0.06))
            .navigationTitle("DhobiGhat")
        }
    }
}
