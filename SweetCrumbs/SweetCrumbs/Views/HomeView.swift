import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cart: CartManager
    @State private var search = ""
    @State private var selectedCategory: ProductCategory?
    @State private var toast: String?
    @State private var showGiftAlert = false
    @FocusState private var searchFocused: Bool

    private var isFiltering: Bool { !search.isEmpty || selectedCategory != nil }

    /// Search + category filter. Without filters we show the "Popular" products.
    private var products: [Product] {
        Product.samples.filter { p in
            let matchesCategory = selectedCategory == nil || p.category == selectedCategory
            let matchesSearch = search.isEmpty
                || p.name.localizedCaseInsensitiveContains(search)
                || p.blurb.localizedCaseInsensitiveContains(search)
                || p.category.rawValue.localizedCaseInsensitiveContains(search)
            let popularOnly = isFiltering || p.isPopular
            return matchesCategory && matchesSearch && popularOnly
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let word = hour < 12 ? "morning" : (hour < 17 ? "afternoon" : "evening")
        return "Good \(word), \(appState.user.firstName)! 👋"
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header(proxy)
                    SearchBar(text: $search, isFocused: $searchFocused).id("search")
                    if !isFiltering { banner }
                    categories
                    if !isFiltering { offers; featureCards }
                    productSection
                }
                .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Theme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toast($toast)
        .productDestination()
        .alert("Gift Mode is on 🎁", isPresented: $showGiftAlert) {
            Button("Start Shopping") { appState.selectedTab = .explore }
            Button("Later", role: .cancel) {}
        } message: { Text("Add your favorite treats, then choose wrapping, a message and delivery date at checkout.") }
    }

    // MARK: Sections

    private func header(_ proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            Button { appState.selectedTab = .profile } label: {
                Text(appState.user.initials)
                    .font(.headline).foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Theme.brandGradient, in: Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting).font(.system(.headline, design: .serif)).foregroundStyle(Theme.text)
                Text("Let's find something sweet").font(.caption).foregroundStyle(Theme.subtext)
            }
            Spacer()
            Button {
                withAnimation { proxy.scrollTo("search", anchor: .top) }
                searchFocused = true
            } label: { circleIcon("magnifyingglass") }
            NavigationLink { NotificationsView() } label: {
                circleIcon("bell.fill").overlay(alignment: .topTrailing) {
                    if appState.unreadCount > 0 {
                        Circle().fill(Theme.rose).frame(width: 10, height: 10).offset(x: -2, y: 2)
                    }
                }
            }
        }
    }

    private func circleIcon(_ name: String) -> some View {
        Image(systemName: name).foregroundStyle(Theme.text)
            .frame(width: 42, height: 42).background(Theme.card, in: Circle())
            .shadow(color: Theme.chocolate.opacity(0.08), radius: 6, y: 3)
    }

    private var banner: some View {
        ZStack(alignment: .leading) {
            LinearGradient(colors: [Theme.peach, Theme.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            Text("🥐").font(.system(size: 90)).rotationEffect(.degrees(-15)).offset(x: 210, y: -30).opacity(0.9)
            Text("🍰").font(.system(size: 60)).offset(x: 235, y: 55)
            VStack(alignment: .leading, spacing: 8) {
                Text("Freshly Baked\nHappiness")
                    .font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(Theme.chocolate)
                Text("Get 20% OFF on your first order")
                    .font(.footnote.weight(.medium)).foregroundStyle(Theme.chocolate.opacity(0.85))
                Button {
                    _ = cart.applyCoupon("SWEET20")
                    toast = "SWEET20 applied 🎉"
                    appState.selectedTab = .explore
                } label: {
                    Text("Order Now").font(.subheadline.bold()).foregroundStyle(.white)
                        .padding(.horizontal, 22).padding(.vertical, 10)
                        .background(Theme.chocolate, in: Capsule())
                }
                .buttonStyle(PressableStyle())
                .padding(.top, 4)
            }
            .padding(22)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Theme.rose.opacity(0.25), radius: 14, y: 8)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private var categories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ProductCategory.allCases) { cat in
                    CategoryCard(category: cat, isSelected: selectedCategory == cat) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedCategory = (selectedCategory == cat) ? nil : cat   // tap again to clear
                        }
                    }
                }
            }
            .padding(.vertical, 8).padding(.horizontal, 4)
        }
        .padding(.horizontal, -4)
    }

    private var offers: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Offers & Deals 🎁").font(.system(.title3, design: .serif).bold()).foregroundStyle(Theme.text)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Offer.samples) { offer in
                        OfferCard(offer: offer) {
                            // Tapping an offer applies its coupon code automatically.
                            let ok = cart.applyCoupon(offer.code)
                            toast = ok ? "\(offer.code) applied to your cart ✅" : "Invalid coupon"
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    private var featureCards: some View {
        HStack(spacing: 14) {
            NavigationLink { CakeBuilderView() } label: {
                featureCard("Cake Builder", "Design your dream cake", "🎂", [Theme.chocolate, Theme.caramel])
            }
            .buttonStyle(PressableStyle())
            Button {
                cart.isGift = true
                showGiftAlert = true
            } label: {
                featureCard("Gift Mode", "Send a sweet surprise", "🎁", [Theme.rose, Theme.peach])
            }
            .buttonStyle(PressableStyle())
        }
    }

    private func featureCard(_ title: String, _ subtitle: String, _ emoji: String, _ colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(emoji).font(.system(size: 34))
            Text(title).font(.system(.headline, design: .serif))
            Text(subtitle).font(.caption).opacity(0.9).multilineTextAlignment(.leading)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: colors[0].opacity(0.3), radius: 8, y: 5)
    }

    private var productSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(isFiltering ? "Results (\(products.count))" : "Popular Today 🔥")
                    .font(.system(.title3, design: .serif).bold()).foregroundStyle(Theme.text)
                Spacer()
                if isFiltering {
                    Button("Clear") { withAnimation { search = ""; selectedCategory = nil } }
                        .font(.subheadline.bold()).foregroundStyle(Theme.rose)
                }
            }
            if products.isEmpty {
                EmptyStateView(emoji: "🔍", title: "Nothing found",
                               message: "Try another search or pick a different category.")
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 14) {
                    ForEach(products) { product in
                        ProductCard(product: product)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: products)
            }
        }
    }
}
