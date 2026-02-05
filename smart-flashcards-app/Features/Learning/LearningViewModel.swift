import Foundation
import SwiftUI
import UIKit

enum LearningState: Equatable {
    case loading
    case showingQuestion(Card)
    case showingAnswer(Card)
    case submitting(Card)
    case completed
    case error(String)

    static func == (lhs: LearningState, rhs: LearningState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.showingQuestion(let lCard), .showingQuestion(let rCard)):
            return lCard.uniqueId == rCard.uniqueId
        case (.showingAnswer(let lCard), .showingAnswer(let rCard)):
            return lCard.uniqueId == rCard.uniqueId
        case (.submitting(let lCard), .submitting(let rCard)):
            return lCard.uniqueId == rCard.uniqueId
        case (.completed, .completed):
            return true
        case (.error(let lMsg), .error(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}

@MainActor
@Observable
final class LearningViewModel {
    private(set) var state: LearningState = .loading
    private(set) var cardsReviewed: Int = 0
    private(set) var daysAhead: Int = 0

    private let stackId: String

    init(stackId: String) {
        self.stackId = stackId
    }

    var currentCard: Card? {
        switch state {
        case .showingQuestion(let card), .showingAnswer(let card), .submitting(let card):
            return card
        default:
            return nil
        }
    }

    var isShowingAnswer: Bool {
        if case .showingAnswer = state {
            return true
        }
        return false
    }

    var isSubmitting: Bool {
        if case .submitting = state {
            return true
        }
        return false
    }

    func loadNextCard() async {
        state = .loading

        do {
            if let card = try await StackService.fetchNextCard(stackId: stackId, daysAhead: daysAhead) {
                state = .showingQuestion(card)
            } else {
                state = .completed
            }
        } catch {
            print("[LearningViewModel] Load error: \(error)")
            state = .error(Strings.Learning.loadError)
            triggerErrorHaptic()
        }
    }

    func revealAnswer() {
        guard case .showingQuestion(let card) = state else { return }
        state = .showingAnswer(card)
        triggerLightHaptic()
    }

    func submitRating(difficultyId: Int64) async {
        guard case .showingAnswer(let card) = state else { return }

        state = .submitting(card)

        do {
            try await StackService.submitCardRating(
                stackId: stackId,
                cardId: card.uniqueId,
                difficultyId: difficultyId
            )
            cardsReviewed += 1
            triggerSuccessHaptic()
            await loadNextCard()
        } catch {
            print("[LearningViewModel] Rating error: \(error)")
            state = .error(Strings.Learning.ratingError)
            triggerErrorHaptic()
        }
    }

    func learnAhead() async {
        daysAhead += 1
        await loadNextCard()
    }

    func retry() async {
        await loadNextCard()
    }

    private func triggerErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
