import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: CartManager
    @EnvironmentObject var appState: AppState
    @State private var couponInput = ""
    @State private var couponMessage: String?
    @State private var couponOK = false

    var body: some View {
        Group {
            if cart.items.isEmpty {
                EmptyStateView(emoji: "🛒", title: "Your cart is empty",
                               message: "Looks like you haven't added any treats yet.",
                               buttonTitle: "Browse Bakery") { appState.selectedTab = .explore }
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(cart.items) { item in
                            CartRow(item: item)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                        removal: .move(edge: .leading).combined(with: .opacity)))
                        }
                        couponSection
                        summary
                    }
                    .padding(20)
                }
                .safeAreaInset(edge: .bottom) {
                    NavigationLink { CheckoutView() } label: {
                        PrimaryLabel(title: "Proceed to Checkout", icon: "arrow.right.circle.fill")
                    }
                    .buttonStyle(PressableStyle())
                    .padding(.horizontal, 20).padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: cart.items.count)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("My Cart")
        .onAppear { couponInput = cart.couponCode ?? "" }
    }

    private var couponSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "tag.fill").foregroundStyle(Theme.caramel)
                TextField("Coupon code", text: $couponInput)
                    .textInputAutocapitalization(.characters).autocorrectionDisabled()
                Button("Apply") {
                    couponOK = cart.applyCoupon(couponInput)
                    couponMessage = couponOK ? "Coupon \(couponInput.uppercased()) applied 🎉" : "That code isn't valid."
                }
                .fontWeight(.bold).foregroundStyle(Theme.rose)
            }
            .padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            if let couponMessage {
                Text(couponMessage).font(.caption).foregroundStyle(couponOK ? .green : .red)
            }
            Text("Try SWEET20, BUY2GET1 or FREEDEL").font(.caption2).foregroundStyle(Theme.subtext)
        }
    }

    private var summary: some View {
        VStack(spacing: 10) {
            SummaryRow(title: "Subtotal", value: cart.subtotal.rupees)
            if cart.discount > 0 {
                SummaryRow(title: "Discount (\(cart.couponCode ?? ""))", value: "-\(cart.discount.rupees)", color: .green)
            }
            SummaryRow(title: "Delivery", value: cart.deliveryCharge == 0 ? "FREE" : cart.deliveryCharge.rupees)
            if cart.giftWrapFee > 0 { SummaryRow(title: "Gift wrapping", value: cart.giftWrapFee.rupees) }
            Divider()
            SummaryRow(title: "Total", value: cart.total.rupees, bold: true)
        }
        .cardStyle()
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    var bold = false
    var color: Color = Theme.text
    var body: some View {
        HStack {
            Text(title).foregroundStyle(bold ? Theme.text : Theme.subtext)
            Spacer()
            Text(value).foregroundStyle(bold ? Theme.rose : color)
        }
        .font(bold ? .title3.bold() : .subheadline)
    }
}

struct CartRow: View {
    let item: CartItem
    @EnvironmentObject var cart: CartManager

    var body: some View {
        HStack(spacing: 14) {
            ProductArt(product: item.product, emojiSize: 38)
                .frame(width: 78, height: 78)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name).font(.system(.subheadline, design: .serif).bold())
                    .foregroundStyle(Theme.text).lineLimit(1)
                Text(item.optionsSummary).font(.caption).foregroundStyle(Theme.subtext).lineLimit(2)
                HStack {
                    Text(item.total.rupees).font(.headline).foregroundStyle(Theme.rose)
                        .contentTransition(.numericText())
                    Spacer()
                    QuantityStepper(quantity: item.quantity,
                                    onMinus: { withAnimation { cart.changeQuantity(of: item.id, by: -1) } },
                                    onPlus: { withAnimation { cart.changeQuantity(of: item.id, by: 1) } })
                    .scaleEffect(0.85, anchor: .trailing)
                }
            }
            Button { withAnimation { cart.remove(item.id) } } label: {
                Image(systemName: "trash").foregroundStyle(.red.opacity(0.8))
            }
        }
        .cardStyle(padding: 12)
    }
}
