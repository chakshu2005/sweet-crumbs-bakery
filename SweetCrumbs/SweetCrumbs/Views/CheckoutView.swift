import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cart: CartManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var street = ""
    @State private var city = ""
    @State private var pincode = ""
    @State private var payment: PaymentMethod = .upi
    @State private var errorMessage: String?
    @State private var placedOrder: Order?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                block("Delivery Address 📍") {
                    field("Full name", $name, icon: "person.fill")
                    field("Phone number", $phone, icon: "phone.fill", keyboard: .numberPad)
                    field("Address", $street, icon: "house.fill")
                    HStack(spacing: 10) {
                        field("City", $city, icon: "building.2.fill")
                        field("Pincode", $pincode, icon: "mappin", keyboard: .numberPad)
                    }
                }

                block("Delivery Options 🚚") {
                    ForEach(DeliveryOption.allCases) { option in
                        OptionRow(icon: option.icon, title: option.rawValue, subtitle: option.eta,
                                  trailing: option.fee == 0 ? "Free" : option.fee.rupees,
                                  selected: cart.deliveryOption == option) {
                            withAnimation(.spring) { cart.deliveryOption = option }
                        }
                    }
                }

                block("Gift Mode 🎁") {
                    Toggle("This order is a gift", isOn: $cart.isGift.animation(.spring)).tint(Theme.rose)
                    if cart.isGift {
                        Toggle("Gift wrapping (+₹59)", isOn: $cart.giftWrap).tint(Theme.rose)
                        TextField("Personal message", text: $cart.giftMessage, axis: .vertical)
                            .lineLimit(2...4)
                            .padding(12)
                            .background(Theme.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        DatePicker("Delivery date", selection: $cart.giftDate, in: Date.now..., displayedComponents: .date)
                    }
                }

                block("Payment Method 💳") {
                    ForEach(PaymentMethod.allCases) { method in
                        OptionRow(icon: method.icon, title: method.rawValue, subtitle: nil, trailing: nil,
                                  selected: payment == method) {
                            withAnimation(.spring) { payment = method }
                        }
                    }
                }

                block("Order Summary 🧾") {
                    ForEach(cart.items) { item in
                        HStack {
                            Text("\(item.quantity) × \(item.product.name)").lineLimit(1)
                            Spacer()
                            Text(item.total.rupees)
                        }
                        .font(.subheadline).foregroundStyle(Theme.text)
                    }
                    Divider()
                    SummaryRow(title: "Subtotal", value: cart.subtotal.rupees)
                    if cart.discount > 0 { SummaryRow(title: "Discount", value: "-\(cart.discount.rupees)", color: .green) }
                    SummaryRow(title: "Delivery", value: cart.deliveryCharge == 0 ? "FREE" : cart.deliveryCharge.rupees)
                    if cart.giftWrapFee > 0 { SummaryRow(title: "Gift wrapping", value: cart.giftWrapFee.rupees) }
                    Divider()
                    SummaryRow(title: "Total", value: cart.total.rupees, bold: true)
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "Place Order • \(cart.total.rupees)", icon: "checkmark.seal.fill", action: placeOrder)
                .padding(.horizontal, 20).padding(.vertical, 8)
                .background(.ultraThinMaterial)
        }
        .onAppear {
            if name.isEmpty { name = appState.user.name == "Guest" ? "" : appState.user.name }
        }
        .alert("Please check your details", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(errorMessage ?? "") }
        // Success screen: when it closes, go back Home.
        .fullScreenCover(item: $placedOrder, onDismiss: {
            appState.selectedTab = .home
            dismiss()
        }) { order in
            OrderSuccessView(order: order) { placedOrder = nil }
        }
    }

    // MARK: Helpers

    private func block<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(.headline, design: .serif)).foregroundStyle(Theme.text)
            content()
        }
        .cardStyle()
    }

    private func field(_ placeholder: String, _ text: Binding<String>, icon: String,
                       keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(Theme.caramel).frame(width: 20)
            TextField(placeholder, text: text).keyboardType(keyboard)
        }
        .padding(12)
        .background(Theme.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func placeOrder() {
        let digits = phone.filter(\.isNumber)
        if name.trimmingCharacters(in: .whitespaces).isEmpty { errorMessage = "Please enter your name."; return }
        if digits.count != 10 { errorMessage = "Phone number must be 10 digits."; return }
        if cart.deliveryOption != .pickup {
            if street.trimmingCharacters(in: .whitespaces).isEmpty { errorMessage = "Please enter your address."; return }
            if city.trimmingCharacters(in: .whitespaces).isEmpty { errorMessage = "Please enter your city."; return }
            if pincode.filter(\.isNumber).count != 6 { errorMessage = "Pincode must be 6 digits."; return }
        }
        let address = Address(name: name, phone: digits,
                              street: cart.deliveryOption == .pickup ? "Sweet Crumbs Store, MG Road" : street,
                              city: cart.deliveryOption == .pickup ? "Delhi" : city,
                              pincode: cart.deliveryOption == .pickup ? "110001" : pincode)
        let order = appState.placeOrder(cart: cart, address: address, delivery: cart.deliveryOption, payment: payment)
        cart.clear()
        placedOrder = order
    }
}

/// Selectable row used for delivery and payment choices.
struct OptionRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let trailing: String?
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(Theme.caramel).frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).foregroundStyle(Theme.text)
                    if let subtitle { Text(subtitle).font(.caption).foregroundStyle(Theme.subtext) }
                }
                Spacer()
                if let trailing { Text(trailing).font(.footnote.bold()).foregroundStyle(Theme.subtext) }
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? Theme.rose : Theme.subtext)
            }
            .padding(12)
            .background(selected ? Theme.pink.opacity(0.25) : Theme.background,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Order confirmation

extension Order: Equatable { static func == (l: Order, r: Order) -> Bool { l.id == r.id } }

struct OrderSuccessView: View {
    let order: Order
    let onDone: () -> Void
    @State private var pop = false
    @State private var drawn = false
    @State private var fall = false

    private struct Piece: Identifiable {
        let id = UUID()
        let emoji: String
        let x: CGFloat
        let delay: Double
        let size: CGFloat
    }
    @State private var pieces: [Piece] = (0..<20).map { _ in
        Piece(emoji: ["🎉", "🧁", "🍪", "✨", "🍩", "🎂"].randomElement()!,
              x: .random(in: 0...1), delay: .random(in: 0...0.8), size: .random(in: 20...34))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                GeometryReader { geo in
                    ForEach(pieces) { p in
                        Text(p.emoji).font(.system(size: p.size))
                            .position(x: p.x * geo.size.width, y: fall ? geo.size.height + 60 : -60)
                            .animation(.easeIn(duration: 2.8).delay(p.delay), value: fall)
                    }
                }
                .allowsHitTesting(false)

                VStack(spacing: 18) {
                    Spacer()
                    ZStack {
                        Circle().fill(Theme.pink.opacity(0.35)).frame(width: 160).scaleEffect(pop ? 1 : 0.3)
                        Circle().trim(from: 0, to: drawn ? 1 : 0)
                            .stroke(Theme.rose, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90)).frame(width: 136)
                        Image(systemName: "checkmark")
                            .font(.system(size: 58, weight: .bold)).foregroundStyle(Theme.rose)
                            .scaleEffect(pop ? 1 : 0)
                    }
                    Text("🎉 Order Confirmed!")
                        .font(.system(size: 30, weight: .bold, design: .serif)).foregroundStyle(Theme.text)
                    Text("Your delicious treats are on their way.")
                        .font(.subheadline).foregroundStyle(Theme.subtext)
                    VStack(spacing: 6) {
                        Text("Order #\(order.number)").font(.headline).foregroundStyle(Theme.text)
                        Text("Estimated: \(order.delivery.eta)").font(.subheadline).foregroundStyle(Theme.rose)
                    }
                    .cardStyle().padding(.top, 8)
                    Spacer()
                    NavigationLink { OrderTrackingView(orderID: order.id) } label: {
                        PrimaryLabel(title: "Track Order", icon: "shippingbox.fill")
                    }
                    .buttonStyle(PressableStyle())
                    Button("Back to Home", action: onDone)
                        .font(.headline).foregroundStyle(Theme.rose).padding(.bottom, 10)
                }
                .padding(24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) { pop = true }
            withAnimation(.easeOut(duration: 0.9)) { drawn = true }
            fall = true
        }
    }
}
