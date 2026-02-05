import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class StackDetailViewModel {
    var cards: [Card] = []
    var isLoading = false
    var errorMessage: String?

    private let stackUniqueId: String

    init(stack: Stack) {
        self.stackUniqueId = stack.uniqueId
        self.cards = stack.cards
    }

    func loadStack() async {
        isLoading = true
        errorMessage = nil

        do {
            let stack = try await StackService.fetchStack(uniqueId: stackUniqueId)
            cards = stack.cards
        } catch let error as APIError {
            print("[StackDetailViewModel] Load error: \(error)")
            errorMessage = error.userMessage
            triggerErrorHaptic()
        } catch {
            print("[StackDetailViewModel] Load unknown error: \(error)")
            errorMessage = Strings.Card.loadError
            triggerErrorHaptic()
        }

        isLoading = false
    }

    func deleteCard(_ card: Card) async {
        guard let index = cards.firstIndex(where: { $0.uniqueId == card.uniqueId }) else {
            return
        }

        let deletedCard = cards[index]

        withAnimation {
            cards.remove(at: index)
        }

        do {
            try await StackService.deleteCard(
                stackId: stackUniqueId,
                cardId: card.uniqueId,
                question: card.question,
                answer: card.answer
            )
            triggerSuccessHaptic()
        } catch let error as APIError {
            print("[StackDetailViewModel] Delete error: \(error)")
            withAnimation {
                cards.insert(deletedCard, at: min(index, cards.count))
            }
            errorMessage = error.userMessage
            triggerErrorHaptic()
        } catch {
            print("[StackDetailViewModel] Delete unknown error: \(error)")
            withAnimation {
                cards.insert(deletedCard, at: min(index, cards.count))
            }
            errorMessage = Strings.Card.deleteError
            triggerErrorHaptic()
        }
    }

    private func triggerErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
