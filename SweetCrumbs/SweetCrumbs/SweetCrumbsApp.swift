import SwiftUI

@main
struct SweetCrumbsApp: App {
    // App-wide state objects, injected into the environment for every screen.
    @StateObject private var appState = AppState()
    @StateObject private var cart = CartManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(cart)
                .tint(Theme.rose)
        }
    }
}

/// Switches between the login flow and the main app with a smooth transition.
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            if appState.isLoggedIn {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 1.03)))
            } else {
                NavigationStack { LoginView() }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.isLoggedIn)
    }
}
