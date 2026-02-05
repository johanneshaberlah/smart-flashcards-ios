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
}
