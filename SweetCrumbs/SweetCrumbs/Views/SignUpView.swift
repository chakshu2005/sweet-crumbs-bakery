import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var errors: [String: String] = [:]
    @State private var serverError: String?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("🎂").font(.system(size: 60)).padding(.top, 10)
                    Text("Create your account")
                        .font(.system(.title, design: .serif).bold()).foregroundStyle(Theme.text)
                    Text("Join Sweet Crumbs and get 20% off your first order.")
                        .font(.subheadline).foregroundStyle(Theme.subtext).multilineTextAlignment(.center)

                    AuthField(icon: "person.fill", placeholder: "Full name", text: $name, error: errors["name"])
                    AuthField(icon: "envelope.fill", placeholder: "Email", text: $email,
                              keyboard: .emailAddress, error: errors["email"])
                    AuthField(icon: "lock.fill", placeholder: "Password (min 6 characters)", text: $password,
                              isSecure: true, error: errors["password"])
                    AuthField(icon: "lock.rotation", placeholder: "Confirm password", text: $confirm,
                              isSecure: true, error: errors["confirm"])
                    PrimaryButton(title: "Create Account", icon: "sparkles", action: submit).padding(.top, 8)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't sign up", isPresented: Binding(get: { serverError != nil }, set: { if !$0 { serverError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(serverError ?? "") }
    }

    private func submit() {
        var e: [String: String] = [:]
        if name.trimmingCharacters(in: .whitespaces).count < 2 { e["name"] = "Please enter your name" }
        if !email.isValidEmail { e["email"] = "Please enter a valid email address" }
        if password.count < 6 { e["password"] = "Password must be at least 6 characters" }
        if confirm != password { e["confirm"] = "Passwords don't match" }
        errors = e
        guard e.isEmpty else { return }
        // Success automatically logs in and RootView switches to the Home screen.
        serverError = appState.register(name: name, email: email, password: password)
    }
}
