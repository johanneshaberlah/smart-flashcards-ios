import Foundation
import SwiftUI
import UIKit

enum CardDetailMode {
    case create
    case edit(Card)
}

@MainActor
@Observable
final class CardDetailViewModel {
    var question: String = ""
    var answer: String = ""
    var isLoading = false
    var errorMessage: String?

    let mode: CardDetailMode
    private let stackId: String

    init(stackId: String, mode: CardDetailMode) {
        self.stackId = stackId
        self.mode = mode

        if case .edit(let card) = mode {
            self.question = card.question
            self.answer = card.answer
        }
    }

    var isEditMode: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }

    private var cardId: String? {
        if case .edit(let card) = mode {
            return card.uniqueId
        }
        return nil
    }

    func validate() -> Bool {
        errorMessage = nil

        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuestion.isEmpty {
            errorMessage = Strings.Card.emptyQuestion
            triggerErrorHaptic()
            return false
        }

        if trimmedAnswer.isEmpty {
            errorMessage = Strings.Card.emptyAnswer
            triggerErrorHaptic()
            return false
        }

        return true
    }

    func save() async throws -> Card {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let card: Card
            if case .edit(let existingCard) = mode {
                card = try await StackService.updateCard(
                    stackId: stackId,
                    cardId: existingCard.uniqueId,
                    question: trimmedQuestion,
                    answer: trimmedAnswer
                )
            } else {
                card = try await StackService.createCard(
                    stackId: stackId,
                    question: trimmedQuestion,
                    answer: trimmedAnswer
                )
            }
            triggerSuccessHaptic()
            return card
        } catch let error as APIError {
            print("[CardDetailViewModel] Save error: \(error)")
            errorMessage = error.userMessage
            triggerErrorHaptic()
            throw error
        } catch {
            print("[CardDetailViewModel] Save unknown error: \(error)")
            errorMessage = Strings.Card.saveError
            triggerErrorHaptic()
            throw error
        }
    }

    func delete() async throws {
        guard case .edit(let card) = mode else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await StackService.deleteCard(
                stackId: stackId,
                cardId: card.uniqueId,
                question: card.question,
                answer: card.answer
            )
            triggerSuccessHaptic()
        } catch let error as APIError {
            print("[CardDetailViewModel] Delete error: \(error)")
            errorMessage = error.userMessage
            triggerErrorHaptic()
            throw error
        } catch {
            print("[CardDetailViewModel] Delete unknown error: \(error)")
            errorMessage = Strings.Card.deleteError
            triggerErrorHaptic()
            throw error
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
