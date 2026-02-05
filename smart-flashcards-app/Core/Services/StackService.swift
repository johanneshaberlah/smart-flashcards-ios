import Foundation

enum StackService {
    static func fetchStacks() async throws -> [Stack] {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        return try await APIClient.shared.request(
            endpoint: .stacks,
            token: token
        )
    }

    static func createStack(name: String, color: String) async throws -> Stack {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        let request = CreateStackRequest(name: name, color: color)
        return try await APIClient.shared.request(
            endpoint: .createStack,
            body: request,
            token: token
        )
    }

    static func deleteStack(uniqueId: String) async throws {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        try await APIClient.shared.requestVoid(
            endpoint: .deleteStack(uniqueId: uniqueId),
            token: token
        )
    }

    static func fetchStack(uniqueId: String) async throws -> Stack {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        return try await APIClient.shared.request(
            endpoint: .stack(uniqueId: uniqueId),
            token: token
        )
    }

    static func deleteCard(stackId: String, cardId: String, question: String, answer: String) async throws {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        let request = DeleteCardRequest(
            stackId: stackId,
            cardId: cardId,
            question: question,
            answer: answer
        )

        try await APIClient.shared.requestVoidWithBody(
            endpoint: .deleteCard(stackId: stackId, cardId: cardId),
            body: request,
            token: token
        )
    }

    static func createCard(stackId: String, question: String, answer: String) async throws -> Card {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        let request = CardRequest(
            stackId: stackId,
            cardId: nil,
            question: question,
            answer: answer
        )

        return try await APIClient.shared.request(
            endpoint: .createCard,
            body: request,
            token: token
        )
    }

    static func updateCard(stackId: String, cardId: String, question: String, answer: String) async throws -> Card {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        let request = CardRequest(
            stackId: stackId,
            cardId: cardId,
            question: question,
            answer: answer
        )

        return try await APIClient.shared.request(
            endpoint: .updateCard(stackId: stackId, cardId: cardId),
            body: request,
            token: token
        )
    }

    static func createCardsFromFile(
        stackId: String,
        pdfData: Data,
        filename: String,
        customInstructions: String
    ) async throws {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        var formData = MultipartFormData()
        formData.append(file: "file", filename: filename, mimeType: "application/pdf", fileData: pdfData)
        formData.append(field: "custom-instructions", value: customInstructions)

        try await APIClient.shared.uploadMultipartFormData(
            endpoint: .createFromFile(stackId: stackId),
            formData: formData,
            token: token
        )
    }

    static func fetchNextCard(stackId: String, daysAhead: Int = 0) async throws -> Card? {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        do {
            return try await APIClient.shared.request(
                endpoint: .nextCard(stackId: stackId, daysAhead: daysAhead),
                token: token
            )
        } catch APIError.httpError(let statusCode, _) where statusCode == 404 {
            return nil
        }
    }

    static func submitCardRating(stackId: String, cardId: String, difficultyId: Int64) async throws {
        guard let token = KeychainService.getToken() else {
            throw APIError.unauthorized
        }

        let request = CardRatingRequest(
            stackId: stackId,
            cardId: cardId,
            difficultyId: difficultyId
        )

        try await APIClient.shared.requestVoidWithBody(
            endpoint: .submitRating,
            body: request,
            token: token
        )
    }
}
