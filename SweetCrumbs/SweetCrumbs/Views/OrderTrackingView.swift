import SwiftUI

struct OrderTrackingView: View {
    let orderID: UUID
    @EnvironmentObject var appState: AppState

    private var order: Order? { appState.orders.first { $0.id == orderID } }

    var body: some View {
        ScrollView {
            if let order {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Order #\(order.number)").font(.system(.title2, design: .serif).bold())
                        Label(order.stage == .delivered ? "Delivered" : "Arriving in \(order.delivery.eta)",
                              systemImage: "clock.fill")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(20)
                    .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    // Progress tracker
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(OrderStage.allCases) { stage in
                            stageRow(stage, current: order.stage)
                        }
                    }
                    .cardStyle()

                    // Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Items ordered").font(.system(.headline, design: .serif))
                        ForEach(order.items) { item in
                            HStack {
                                Text(item.product.emoji)
                                Text("\(item.quantity) × \(item.product.name)").lineLimit(1)
                                Spacer()
                                Text(item.total.rupees)
                            }
                            .font(.subheadline)
                        }
                        Divider()
                        SummaryRow(title: "Total paid (\(order.payment.rawValue))", value: order.total.rupees, bold: true)
                    }
                    .foregroundStyle(Theme.text).cardStyle()

                    // Address
                    VStack(alignment: .leading, spacing: 6) {
                        Text(order.delivery == .pickup ? "Pickup location" : "Delivery address")
                            .font(.system(.headline, design: .serif))
                        Text(order.address.name).fontWeight(.semibold)
                        Text(order.address.oneLine).foregroundStyle(Theme.subtext)
                        Text("📞 \(order.address.phone)").foregroundStyle(Theme.subtext)
                        if order.isGift {
                            Text("🎁 Gift" + (order.giftMessage.isEmpty ? "" : ": “\(order.giftMessage)”"))
                                .foregroundStyle(Theme.rose).padding(.top, 4)
                        }
                    }
                    .font(.subheadline).foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity, alignment: .leading).cardStyle()
                }
                .padding(20)
            } else {
                EmptyStateView(emoji: "📦", title: "Order not found", message: "We couldn't find this order.")
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Track Order")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stageRow(_ stage: OrderStage, current: OrderStage) -> some View {
        let done = stage.rawValue < current.rawValue || current == .delivered
        let isCurrent = stage == current && current != .delivered
        return HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    if done {
                        Circle().fill(Theme.rose)
                        Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                    } else if isCurrent {
                        PulsingDot()
                    } else {
                        Circle().stroke(Theme.subtext.opacity(0.5), lineWidth: 2)
                    }
                }
                .frame(width: 28, height: 28)
                if stage != .delivered {
                    Rectangle()
                        .fill(done ? Theme.rose : Theme.pink.opacity(0.4))
                        .frame(width: 3, height: 34)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(stage.title).font(.subheadline.bold())
                    .foregroundStyle(done || isCurrent ? Theme.text : Theme.subtext)
                Text(stage.caption).font(.caption).foregroundStyle(Theme.subtext)
            }
            .padding(.top, 4)
            Spacer()
        }
    }
}

private struct PulsingDot: View {
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle().fill(Theme.rose.opacity(0.3)).scaleEffect(pulse ? 1.5 : 1).opacity(pulse ? 0 : 1)
            Circle().fill(Theme.rose).frame(width: 16, height: 16)
        }
        .onAppear { withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) { pulse = true } }
    }
}
