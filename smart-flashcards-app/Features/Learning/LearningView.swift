import SwiftUI

struct LearningView: View {
    let stackId: String
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: LearningViewModel

    init(stackId: String, onDismiss: @escaping () -> Void) {
        self.stackId = stackId
        self.onDismiss = onDismiss
        self._viewModel = State(initialValue: LearningViewModel(stackId: stackId))
    }

    var body: some View {
        ZStack {
            backgroundView

            switch viewModel.state {
            case .loading:
                loadingView

            case .showingQuestion(let card), .showingAnswer(let card), .submitting(let card):
                cardSessionView(card: card)

            case .completed:
                LearningCompletionView(
                    cardsReviewed: viewModel.cardsReviewed,
                    onLearnAhead: {
                        Task {
                            await viewModel.learnAhead()
                        }
                    },
                    onFinish: onDismiss
                )

            case .error(let message):
                errorView(message: message)
            }
        }
        .task {
            await viewModel.loadNextCard()
        }
    }

    private var backgroundView: some View {
        Color(uiColor: colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
            .ignoresSafeArea()
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Theme.emerald600)
            Text(Strings.Stack.loading)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private func cardSessionView(card: Card) -> some View {
        VStack(spacing: 0) {
            headerView

            Spacer()

            LearningCardView(
                card: card,
                isFlipped: viewModel.isShowingAnswer,
                onTap: {
                    viewModel.revealAnswer()
                }
            )
            .padding(.horizontal, 24)
            .frame(maxHeight: 400)

            Spacer()

            if viewModel.isShowingAnswer, let options = card.difficultyAndDurations {
                DifficultyButtonsView(
                    difficultyAndDurations: options,
                    isDisabled: viewModel.isSubmitting,
                    onSelect: { difficultyId in
                        Task {
                            await viewModel.submitRating(difficultyId: difficultyId)
                        }
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Spacer()
                    .frame(height: 100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isShowingAnswer)
    }

    private var headerView: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.regular.tint(Theme.gray600).interactive(), in: .circle)

            Spacer()

            if viewModel.cardsReviewed > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.emerald500)
                    Text("\(viewModel.cardsReviewed)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.regularMaterial)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(Theme.red500)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Text(Strings.Learning.close)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .glassEffect(.regular.tint(Theme.gray600).interactive())

                Button {
                    Task {
                        await viewModel.retry()
                    }
                } label: {
                    Text(Strings.Learning.retry)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .glassEffect(.regular.tint(Theme.emerald600).interactive())
            }
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    LearningView(stackId: "stack-1", onDismiss: {})
}
