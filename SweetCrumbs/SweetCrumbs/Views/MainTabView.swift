import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        // The system tab bar is hidden; each tab's root screen shows our CustomTabBar instead.
        TabView(selection: $appState.selectedTab) {
            NavigationStack { HomeView().withTabBar() }
                .toolbar(.hidden, for: .tabBar).tag(AppTab.home)
            NavigationStack { ExploreView().withTabBar() }
                .toolbar(.hidden, for: .tabBar).tag(AppTab.explore)
            NavigationStack { FavoritesView().withTabBar() }
                .toolbar(.hidden, for: .tabBar).tag(AppTab.favorites)
            NavigationStack { CartView().withTabBar() }
                .toolbar(.hidden, for: .tabBar).tag(AppTab.cart)
            NavigationStack { ProfileView().withTabBar() }
                .toolbar(.hidden, for: .tabBar).tag(AppTab.profile)
        }
    }
}
