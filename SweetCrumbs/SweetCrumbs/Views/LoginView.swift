import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var showAlert = false
    @State private var showReset = false
    @State private var resetEmail = ""
    @State private var showResetSent = false
    @State private var isLoading = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            // Soft decorative blobs
            Circle().fill(Theme.pink.opacity(0.35)).frame(width: 300).blur(radius: 60).offset(x: -140, y: -300)
            Circle().fill(Theme.peach.opacity(0.35)).frame(width: 280).blur(radius: 60).offset(x: 160, y: 320)

            ScrollView {
                VStack(spacing: 22) {
                    // Logo
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(Theme.brandGradient).frame(width: 104, height: 104)
                                .shadow(color: Theme.rose.opacity(0.4), radius: 14, y: 8)
                            Text("🧁").font(.system(size: 54))
                        }
                        .scaleEffect(appeared ? 1 : 0.4)
                        Text("Sweet Crumbs")
                            .font(.system(size: 38, weight: .bold, design: .serif))
                            .foregroundStyle(Theme.text)
                        Text("Freshly baked, beautifully made.")
                            .font(.system(.subheadline, design: .serif)).italic()
                            .foregroundStyle(Theme.subtext)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 14) {
                        AuthField(icon: "envelope.fill", placeholder: "Email", text: $email,
                                  keyboard: .emailAddress, error: emailError)
                        AuthField(icon: "lock.fill", placeholder: "Password", text: $password,
                                  isSecure: true, error: passwordError)
                        HStack {
                            Button("Use demo account") {
                                email = "demo@sweetcrumbs.com"; password = "bakery123"
                                emailError = nil; passwordError = nil
                            }
                            Spacer()
                            Button("Forgot Password?") { resetEmail = email; showReset = true }
                        }
                        .font(.footnote.weight(.semibold)).foregroundStyle(Theme.rose)

                        Button(action: login) {
                            ZStack {
                                PrimaryLabel(title: "Login").opacity(isLoading ? 0.6 : 1)
                                if isLoading { ProgressView().tint(.white) }
                            }
                        }
                        .buttonStyle(PressableStyle())
                        .disabled(isLoading)
                    }
                    .offset(y: appeared ? 0 : 30).opacity(appeared ? 1 : 0)

                    // Social login
                    VStack(spacing: 14) {
                        HStack {
                            Rectangle().fill(Theme.subtext.opacity(0.3)).frame(height: 1)
                            Text("or continue with").font(.caption).foregroundStyle(Theme.subtext)
                            Rectangle().fill(Theme.subtext.opacity(0.3)).frame(height: 1)
                        }
                        HStack(spacing: 14) {
                            socialButton("Google", icon: "g.circle.fill")
                            socialButton("Apple", icon: "apple.logo")
                        }
                        HStack(spacing: 4) {
                            Text("Don't have an account?").foregroundStyle(Theme.subtext)
                            NavigationLink("Sign Up") { SignUpView() }
                                .fontWeight(.bold).foregroundStyle(Theme.rose)
                        }
                        .font(.subheadline)
                    }
                    .opacity(appeared ? 1 : 0)
                }
                .padding(.horizontal, 24).padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarHidden(true)
        .onAppear { withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) { appeared = true } }
        .alert("Invalid login details", isPresented: $showAlert) {
            Button("Try Again", role: .cancel) {}
        } message: { Text("The email or password is incorrect.\nTip: use demo@sweetcrumbs.com / bakery123") }
        .alert("Reset Password", isPresented: $showReset) {
            TextField("Email", text: $resetEmail).textInputAutocapitalization(.never).keyboardType(.emailAddress)
            Button("Send Link") { if resetEmail.isValidEmail { showResetSent = true } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("We'll email you a link to reset your password.") }
        .alert("Check your inbox 📬", isPresented: $showResetSent) {
            Button("OK", role: .cancel) {}
        } message: { Text("A reset link has been sent to \(resetEmail).") }
    }

    private func socialButton(_ name: String, icon: String) -> some View {
        Button { appState.socialLogin(provider: name) } label: {
            HStack { Image(systemName: icon); Text(name).fontWeight(.semibold) }
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Theme.chocolate.opacity(0.08), radius: 6, y: 3)
        }
        .buttonStyle(PressableStyle())
    }

    private func login() {
        emailError = email.isValidEmail ? nil : "Please enter a valid email address"
        passwordError = password.count >= 6 ? nil : "Password must be at least 6 characters"
        guard emailError == nil, passwordError == nil else { return }
        isLoading = true
        Task {
            try? await Task.sleep(for: .seconds(0.8))   // fake network delay
            if !appState.login(email: email, password: password) { showAlert = true }
            isLoading = false
        }
    }
}
