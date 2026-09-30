import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var appState: AppState
    private var favorites: [Product] { Product.samples.filter { appState.favorites.contains($0.id) } }

    var body: some View {
        ScrollView {
            if favorites.isEmpty {
                EmptyStateView(emoji: "💝", title: "No favorites yet",
                               message: "Tap the heart on any treat to save it here.",
                               buttonTitle: "Discover Treats") { appState.selectedTab = .explore }
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 14) {
                    ForEach(favorites) { product in
                        ProductCard(product: product)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(20)
                .animation(.spring(response: 0.45, dampingFraction: 0.75), value: favorites)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Favorites ❤️")
        .productDestination()
    }
}
