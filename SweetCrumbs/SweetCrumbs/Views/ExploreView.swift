import SwiftUI

struct ExploreView: View {
    enum Sort: String, CaseIterable, Identifiable {
        case featured = "Featured", priceLow = "Price: Low to High"
        case priceHigh = "Price: High to Low", rating = "Top Rated"
        var id: String { rawValue }
    }

    @State private var search = ""
    @State private var category: ProductCategory?
    @State private var sort: Sort = .featured
    @FocusState private var focused: Bool

    private var results: [Product] {
        var list = Product.samples.filter { p in
            (category == nil || p.category == category)
            && (search.isEmpty || p.name.localizedCaseInsensitiveContains(search) || p.blurb.localizedCaseInsensitiveContains(search))
        }
        switch sort {
        case .featured: break
        case .priceLow: list.sort { $0.price < $1.price }
        case .priceHigh: list.sort { $0.price > $1.price }
        case .rating: list.sort { $0.rating > $1.rating }
        }
        return list
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Explore").font(.system(size: 32, weight: .bold, design: .serif)).foregroundStyle(Theme.text)
                SearchBar(text: $search, placeholder: "Search cakes, cookies, coffee…", isFocused: $focused)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(ProductCategory.allCases) { cat in
                            CategoryCard(category: cat, isSelected: category == cat) {
                                withAnimation(.spring) { category = (category == cat) ? nil : cat }
                            }
                        }
                    }
                    .padding(.vertical, 6).padding(.horizontal, 4)
                }
                .padding(.horizontal, -4)

                NavigationLink { CakeBuilderView() } label: {
                    HStack(spacing: 12) {
                        Text("🎂").font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text("Build your own cake").font(.system(.headline, design: .serif))
                            Text("Pick flavor, frosting & toppings").font(.caption)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.white).padding(16)
                    .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(PressableStyle())

                HStack {
                    Text("\(results.count) treats").font(.subheadline).foregroundStyle(Theme.subtext)
                    Spacer()
                    Menu {
                        Picker("Sort", selection: $sort) {
                            ForEach(Sort.allCases) { Text($0.rawValue).tag($0) }
                        }
                    } label: {
                        Label(sort.rawValue, systemImage: "arrow.up.arrow.down")
                            .font(.subheadline.bold()).foregroundStyle(Theme.rose)
                    }
                }

                if results.isEmpty {
                    EmptyStateView(emoji: "🥺", title: "No treats found", message: "Try a different search.")
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 14) {
                        ForEach(results) { ProductCard(product: $0) }
                    }
                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: results)
                }
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .productDestination()
    }
}
