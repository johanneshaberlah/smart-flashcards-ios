import SwiftUI

struct StackRowView: View {
    let stack: Stack

    var body: some View {
        HStack(spacing: 12) {
            colorBadge

            VStack(alignment: .leading, spacing: 4) {
                Text(stack.name)
                    .font(.headline)
                    .foregroundStyle(Theme.gray900)

                Text(cardCountText)
                    .font(.subheadline)
                    .foregroundStyle(Theme.gray600)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.gray300)
        }
        .padding(.vertical, 4)
    }

    private var colorBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: stack.color))
                .frame(width: 44, height: 44)

            Text(badgeText)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private var badgeText: String {
        let name = stack.name.trimmingCharacters(in: .whitespaces)
        return String(name.prefix(4)).uppercased()
    }

    private var cardCountText: String {
        let count = stack.cards.count
        if count == 1 {
            return Strings.Stack.cardCountSingular
        }
        return String(format: Strings.Stack.cardCount, count)
    }
}

#Preview {
    let stack = Stack(
        id: 1,
        uniqueId: "test-123",
        name: "Mathematik",
        color: "#059669",
        cards: []
    )
    return StackRowView(stack: stack)
        .padding()
}
