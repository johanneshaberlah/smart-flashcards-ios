import SwiftUI

struct DifficultyButtonsView: View {
    let difficultyAndDurations: [DifficultyAndDuration]
    let isDisabled: Bool
    let onSelect: (Int64) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(difficultyAndDurations) { item in
                difficultyButton(for: item)
            }
        }
    }

    private func difficultyButton(for item: DifficultyAndDuration) -> some View {
        Button {
            onSelect(item.difficulty.id)
        } label: {
            VStack(spacing: 4) {
                Text(item.difficulty.name)
                    .font(.subheadline.weight(.semibold))

                Text(item.duration.displayName)
                    .font(.caption)
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .glassEffect(.regular.tint(Color(hex: item.difficulty.color)).interactive())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

#Preview {
    DifficultyButtonsView(
        difficultyAndDurations: [
            DifficultyAndDuration(
                difficulty: Difficulty(id: 1, name: "Schwer", color: "#EF4444"),
                duration: Duration(displayName: "1 Minute")
            ),
            DifficultyAndDuration(
                difficulty: Difficulty(id: 2, name: "Mittel", color: "#F97316"),
                duration: Duration(displayName: "10 Minuten")
            ),
            DifficultyAndDuration(
                difficulty: Difficulty(id: 3, name: "Einfach", color: "#10B981"),
                duration: Duration(displayName: "1 Tag")
            )
        ],
        isDisabled: false,
        onSelect: { _ in }
    )
    .padding()
}
