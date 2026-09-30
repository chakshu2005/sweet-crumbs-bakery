import SwiftUI

private enum Flavor: String, CaseIterable, Identifiable {
    case chocolate = "Chocolate", vanilla = "Vanilla", redVelvet = "Red Velvet"
    case butterscotch = "Butterscotch", strawberry = "Strawberry"
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .chocolate: Color(red: 0.42, green: 0.26, blue: 0.19)
        case .vanilla: Color(red: 0.98, green: 0.90, blue: 0.70)
        case .redVelvet: Color(red: 0.78, green: 0.22, blue: 0.30)
        case .butterscotch: Color(red: 0.90, green: 0.68, blue: 0.32)
        case .strawberry: Color(red: 0.98, green: 0.66, blue: 0.72)
        }
    }
    var extra: Double { self == .redVelvet ? 100 : (self == .vanilla ? 0 : 50) }
}

private enum CakeSize: String, CaseIterable, Identifiable {
    case half = "500 g", one = "1 kg", two = "2 kg"
    var id: String { rawValue }
    var base: Double { switch self { case .half: 549; case .one: 999; case .two: 1899 } }
    var scale: CGFloat { switch self { case .half: 0.75; case .one: 0.9; case .two: 1.05 } }
}

private enum Frosting: String, CaseIterable, Identifiable {
    case buttercream = "Buttercream", ganache = "Chocolate Ganache"
    case creamCheese = "Cream Cheese", whipped = "Whipped Cream"
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .buttercream: Color(red: 1.0, green: 0.95, blue: 0.82)
        case .ganache: Color(red: 0.28, green: 0.17, blue: 0.13)
        case .creamCheese: Color(red: 0.99, green: 0.97, blue: 0.93)
        case .whipped: .white
        }
    }
    var extra: Double { self == .ganache ? 80 : (self == .creamCheese ? 60 : 0) }
}

private enum Topping: String, CaseIterable, Identifiable {
    case fruit = "Fresh Fruit", sprinkles = "Sprinkles", chips = "Choco Chips"
    case flowers = "Edible Flowers", macarons = "Macarons"
    var id: String { rawValue }
    var emoji: String {
        switch self { case .fruit: "🍓"; case .sprinkles: "✨"; case .chips: "🍫"; case .flowers: "🌸"; case .macarons: "🍬" }
    }
    var price: Double { 40 }
}

struct CakeBuilderView: View {
    @EnvironmentObject var cart: CartManager
    @State private var flavor: Flavor = .chocolate
    @State private var size: CakeSize = .one
    @State private var frosting: Frosting = .buttercream
    @State private var toppings: Set<Topping> = []
    @State private var customText = ""
    @State private var toast: String?

    private var textFee: Double { customText.isEmpty ? 0 : 49 }
    private var estimate: Double {
        size.base + flavor.extra + frosting.extra + Double(toppings.count) * 40 + textFee
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                preview
                pickerSection("Flavor") {
                    chips(Flavor.allCases, selected: { $0 == flavor }, label: \.rawValue) { flavor = $0 }
                }
                pickerSection("Size") {
                    chips(CakeSize.allCases, selected: { $0 == size }, label: \.rawValue) { size = $0 }
                }
                pickerSection("Frosting") {
                    chips(Frosting.allCases, selected: { $0 == frosting }, label: \.rawValue) { frosting = $0 }
                }
                pickerSection("Toppings (+₹40 each)") {
                    FlowChips(items: Topping.allCases, isOn: { toppings.contains($0) }, label: { "\($0.emoji) \($0.rawValue)" }) {
                        if toppings.contains($0) { toppings.remove($0) } else { toppings.insert($0) }
                    }
                }
                pickerSection("Custom text (+₹49)") {
                    TextField("e.g. Happy Anniversary!", text: $customText)
                        .onChange(of: customText) { _, new in if new.count > 24 { customText = String(new.prefix(24)) } }
                        .padding(14)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Text("\(customText.count)/24 characters").font(.caption2).foregroundStyle(Theme.subtext)
                }
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Cake Builder")
        .navigationBarTitleDisplayMode(.inline)
        .toast($toast)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: flavor)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: frosting)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: size)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 14) {
                VStack(alignment: .leading) {
                    Text("Estimated price").font(.caption).foregroundStyle(Theme.subtext)
                    Text(estimate.rupees).font(.title2.bold()).foregroundStyle(Theme.text)
                        .contentTransition(.numericText())
                }
                PrimaryButton(title: "Add to Cart", icon: "cart.badge.plus", action: addToCart)
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }

    // Layered cake drawn with shapes; it updates live as you choose.
    private var preview: some View {
        let width = 200 * size.scale
        return VStack(spacing: 0) {
            Text(toppings.isEmpty ? " " : toppings.map(\.emoji).sorted().joined())
                .font(.title2).frame(height: 32)
            ZStack {
                Capsule().fill(frosting.color).frame(width: width, height: 30)
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
                if !customText.isEmpty {
                    Text(customText).font(.system(size: 11, design: .serif).italic().weight(.semibold))
                        .foregroundStyle(frosting == .ganache ? .white : Theme.chocolate)
                        .lineLimit(1).frame(width: width - 30)
                }
            }
            RoundedRectangle(cornerRadius: 10).fill(flavor.color).frame(width: width - 8, height: 54)
            Rectangle().fill(frosting.color).frame(width: width - 8, height: 12)
            RoundedRectangle(cornerRadius: 10).fill(flavor.color).frame(width: width - 8, height: 54)
            Capsule().fill(Theme.card).frame(width: width + 50, height: 14)
                .shadow(color: .black.opacity(0.12), radius: 4, y: 3)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 24)
        .background(LinearGradient(colors: [Theme.pink.opacity(0.4), Theme.peach.opacity(0.4)],
                                   startPoint: .top, endPoint: .bottom),
                    in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func pickerSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(.headline, design: .serif)).foregroundStyle(Theme.text)
            content()
        }
    }

    private func chips<T: Identifiable>(_ items: [T], selected: @escaping (T) -> Bool,
                                        label: KeyPath<T, String>, onTap: @escaping (T) -> Void) -> some View {
        FlowChips(items: items, isOn: selected, label: { $0[keyPath: label] }, onTap: onTap)
    }

    private func addToCart() {
        let toppingNames = toppings.map(\.rawValue).sorted().joined(separator: ", ")
        // Custom cakes become a Product whose id is derived from the recipe, so identical cakes merge in the cart.
        let recipe = "\(flavor.rawValue)|\(size.rawValue)|\(frosting.rawValue)|\(toppingNames)|\(customText)"
        let product = Product(
            id: abs(recipe.hashValue), name: "Custom \(flavor.rawValue) Cake",
            blurb: "\(frosting.rawValue) • \(size.rawValue)",
            details: "Your custom cake: \(flavor.rawValue) sponge, \(frosting.rawValue), \(size.rawValue)"
                + (toppingNames.isEmpty ? "." : " with \(toppingNames)."),
            price: estimate, rating: 5.0, reviews: 0, category: .cakes, emoji: "🎂", tint: flavor.color,
            ingredients: [flavor.rawValue, frosting.rawValue] + toppings.map(\.rawValue))
        cart.add(product, message: customText)
        toast = "Custom cake added to cart 🎂"
    }
}

/// Wrapping row of tappable chips (uses an adaptive grid so it works everywhere).
private struct FlowChips<T: Identifiable>: View {
    let items: [T]
    let isOn: (T) -> Bool
    let label: (T) -> String
    let onTap: (T) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 105), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                let on = isOn(item)
                Button { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { onTap(item) } } label: {
                    Text(label(item)).font(.footnote.weight(.semibold))
                        .foregroundStyle(on ? .white : Theme.text)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(on ? Theme.rose : Theme.card, in: Capsule())
                        .shadow(color: Theme.chocolate.opacity(0.08), radius: 4, y: 2)
                }
                .buttonStyle(PressableStyle())
            }
        }
    }
}
