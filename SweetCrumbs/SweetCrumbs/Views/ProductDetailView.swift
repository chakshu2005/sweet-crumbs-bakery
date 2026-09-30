import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cart: CartManager
    @State private var size: ProductSize = .small
    @State private var quantity = 1
    @State private var addOns: Set<AddOn> = []
    @State private var message = ""
    @State private var toast: String?
    @State private var appeared = false
    @State private var added = false

    private var unitPrice: Double {
        product.price * size.multiplier + addOns.reduce(0) { $0 + $1.price }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero image
                ProductArt(product: product, emojiSize: 130)
                    .frame(height: 300)
                    .scaleEffect(appeared ? 1 : 1.15)
                    .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 36, bottomTrailingRadius: 36))
                    .overlay(alignment: .bottomTrailing) { HeartButton(product: product).padding(18) }

                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.name)
                            .font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(Theme.text)
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill").foregroundStyle(.orange)
                            Text(String(format: "%.1f", product.rating)).fontWeight(.bold)
                            Text("(\(product.reviews) reviews)").foregroundStyle(Theme.subtext)
                            Spacer()
                            Text(unitPrice.rupees)
                                .font(.title2.bold()).foregroundStyle(Theme.rose)
                                .contentTransition(.numericText())
                        }
                        .font(.subheadline)
                    }

                    section("Description") {
                        Text(product.details).font(.subheadline).foregroundStyle(Theme.subtext).lineSpacing(4)
                    }

                    section("Ingredients") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], alignment: .leading, spacing: 8) {
                            ForEach(product.ingredients, id: \.self) { item in
                                Text(item).font(.caption.weight(.semibold)).foregroundStyle(Theme.text)
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(Theme.pink.opacity(0.35), in: Capsule())
                            }
                        }
                    }

                    section("Size") {
                        HStack(spacing: 10) {
                            ForEach(ProductSize.allCases) { s in
                                Button { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { size = s } } label: {
                                    VStack(spacing: 2) {
                                        Text(s.rawValue).font(.subheadline.bold())
                                        Text(s.caption).font(.caption2)
                                    }
                                    .foregroundStyle(size == s ? .white : Theme.text)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(size == s ? Theme.rose : Theme.card,
                                                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Theme.chocolate.opacity(0.08), radius: 5, y: 3)
                                }
                                .buttonStyle(PressableStyle())
                            }
                        }
                    }

                    section("Add-ons") {
                        VStack(spacing: 10) {
                            ForEach(AddOn.allCases) { addOn in addOnRow(addOn) }
                            if addOns.contains(.message) {
                                TextField("e.g. Happy Birthday Riya!", text: $message)
                                    .padding(14)
                                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                    }

                    HStack {
                        Text("Quantity").font(.system(.headline, design: .serif)).foregroundStyle(Theme.text)
                        Spacer()
                        QuantityStepper(quantity: quantity,
                                        onMinus: { if quantity > 1 { quantity -= 1 } },
                                        onPlus: { if quantity < 20 { quantity += 1 } })
                    }
                }
                .padding(20)
                .offset(y: appeared ? 0 : 30).opacity(appeared ? 1 : 0)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Theme.background.ignoresSafeArea())
        .toolbarBackground(.hidden, for: .navigationBar)
        .toast($toast)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: addOns)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: quantity)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 14) {
                VStack(alignment: .leading) {
                    Text("Total").font(.caption).foregroundStyle(Theme.subtext)
                    Text((unitPrice * Double(quantity)).rupees).font(.title3.bold()).foregroundStyle(Theme.text)
                        .contentTransition(.numericText())
                }
                PrimaryButton(title: added ? "Added!" : "Add to Cart", icon: added ? "checkmark" : "cart.badge.plus") {
                    addToCart()
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .onAppear { withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { appeared = true } }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(.headline, design: .serif)).foregroundStyle(Theme.text)
            content()
        }
    }

    private func addOnRow(_ addOn: AddOn) -> some View {
        let on = addOns.contains(addOn)
        return Button {
            if on { addOns.remove(addOn) } else { addOns.insert(addOn) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: addOn.icon).foregroundStyle(Theme.caramel).frame(width: 26)
                Text(addOn.rawValue).foregroundStyle(Theme.text)
                Spacer()
                Text(addOn.price == 0 ? "Free" : "+\(addOn.price.rupees)").font(.footnote).foregroundStyle(Theme.subtext)
                Image(systemName: on ? "checkmark.circle.fill" : "circle").foregroundStyle(on ? Theme.rose : Theme.subtext)
            }
            .padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(on ? Theme.rose : .clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func addToCart() {
        let note = addOns.contains(.message) ? message.trimmingCharacters(in: .whitespaces) : ""
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            cart.add(product, size: size, addOns: addOns, message: note, quantity: quantity)
            added = true
        }
        toast = "Added \(quantity) × \(product.name) 🛒"
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation { added = false }
        }
    }
}

/// Reusable − / + control used on the detail page and in the cart.
struct QuantityStepper: View {
    let quantity: Int
    let onMinus: () -> Void
    let onPlus: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onMinus) { Image(systemName: "minus").frame(width: 32, height: 32) }
            Text("\(quantity)").font(.headline).frame(minWidth: 24).contentTransition(.numericText())
            Button(action: onPlus) { Image(systemName: "plus").frame(width: 32, height: 32) }
        }
        .font(.subheadline.bold())
        .foregroundStyle(Theme.text)
        .buttonStyle(PressableStyle())
        .padding(4)
        .background(Theme.card, in: Capsule())
        .shadow(color: Theme.chocolate.opacity(0.08), radius: 5, y: 3)
    }
}
