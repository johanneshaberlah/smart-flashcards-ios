import SwiftUI

struct LearningCompletionView: View {
    let cardsReviewed: Int
    let onLearnAhead: () -> Void
    let onFinish: () -> Void

    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            checkmarkIcon

            VStack(spacing: 12) {
                Text(Strings.Learning.completionTitle)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.primary)

                Text(Strings.Learning.completionMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text(cardsReviewedText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.emerald600)
                    .padding(.top, 4)
            }

            Spacer()

            VStack(spacing: 12) {
                learnAheadButton
                finishButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                showCheckmark = true
            }
        }
    }

    private var checkmarkIcon: some View {
        ZStack {
            Circle()
                .fill(Theme.emerald500.opacity(0.15))
                .frame(width: 120, height: 120)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.emerald500)
                .scaleEffect(showCheckmark ? 1 : 0.3)
                .opacity(showCheckmark ? 1 : 0)
        }
    }

    private var cardsReviewedText: String {
        if cardsReviewed == 1 {
            return Strings.Learning.cardsReviewedSingular
        } else {
            return String(format: Strings.Learning.cardsReviewed, cardsReviewed)
        }
    }

    private var learnAheadButton: some View {
        Button(action: onLearnAhead) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.forward.circle")
                Text(Strings.Learning.learnAhead)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .glassEffect(.regular.tint(Theme.emerald600).interactive())
    }

    private var finishButton: some View {
        Button(action: onFinish) {
            Text(Strings.Learning.finish)
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .glassEffect(.regular.interactive())
    }
}

#Preview {
    LearningCompletionView(
        cardsReviewed: 12,
        onLearnAhead: {},
        onFinish: {}
    )
}
