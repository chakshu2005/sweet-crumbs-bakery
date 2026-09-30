import SwiftUI

struct EmptyStateView: View {
    let emoji: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    @State private var bob = false

    var body: some View {
        VStack(spacing: 14) {
            Text(emoji).font(.system(size: 70))
                .offset(y: bob ? -6 : 6)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: bob)
            Text(title).font(.system(.title3, design: .serif).bold()).foregroundStyle(Theme.text)
            Text(message).font(.subheadline).foregroundStyle(Theme.subtext).multilineTextAlignment(.center)
            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, action: action).padding(.horizontal, 40).padding(.top, 6)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .onAppear { bob = true }
    }
}
