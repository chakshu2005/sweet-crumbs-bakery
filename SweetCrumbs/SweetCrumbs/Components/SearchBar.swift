import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder = "What are you craving today?"
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.caramel)
            TextField(placeholder, text: $text)
                .focused(isFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button { withAnimation { text = "" } } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.subtext)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Theme.card, in: Capsule())
        .overlay(Capsule().stroke(isFocused.wrappedValue ? Theme.rose : .clear, lineWidth: 1.5))
        .shadow(color: Theme.chocolate.opacity(0.08), radius: 8, y: 4)
        .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
    }
}
