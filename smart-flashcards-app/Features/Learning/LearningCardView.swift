import SwiftUI

struct LearningCardView: View {
    let card: Card
    let isFlipped: Bool
    let onTap: () -> Void

    @State private var rotation: Double = 0
    @State private var showHint = false

    var body: some View {
        ZStack {
            cardFront
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )

            cardBack
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(rotation - 180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
        }
        .onTapGesture {
            if !isFlipped {
                onTap()
            }
        }
        .onChange(of: isFlipped) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                rotation = newValue ? 180 : 0
            }
            if !newValue {
                showHint = false
            }
        }
        .alert(Strings.Learning.hint, isPresented: $showHint) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(card.hint ?? "")
        }
    }

    private var cardFront: some View {
        VStack(spacing: 16) {
            if card.hint != nil && !card.hint!.isEmpty {
                HStack {
                    Spacer()
                    hintButton
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            } else {
                Spacer()
                    .frame(height: 60)
            }

            Spacer()

            Text(card.question)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "hand.tap")
                Text(Strings.Learning.tapToReveal)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBackground)
    }

    private var hintButton: some View {
        Button {
            showHint = true
        } label: {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(Theme.emerald500)
        }
    }

    private var cardBack: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(card.answer)
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Theme.emerald500.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    LearningCardView(
        card: Card(
            id: 1,
            uniqueId: "card-1",
            question: "What is the capital of France?",
            answer: "Paris",
            hint: "It's also known as the City of Light",
            maturity: nil,
            difficultyAndDurations: nil
        ),
        isFlipped: false,
        onTap: {}
    )
    .padding(24)
    .frame(height: 400)
}
