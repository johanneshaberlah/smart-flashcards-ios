import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized"
        }
    }

    var userMessage: String {
        switch self {
        case .httpError(let statusCode, let message):
            // For 400 Bad Request with no message (e.g., login with wrong credentials)
            if statusCode == 400 && message == nil {
                return Strings.APIError.loginFailed
            }
            return mapAPIMessage(message)
        case .networkError:
            return Strings.APIError.networkError
        default:
            return Strings.APIError.unknownError
        }
    }

    private func mapAPIMessage(_ message: String?) -> String {
        print("[APIError] Mapping message: \(message ?? "nil")")

        guard let message = message else {
            return Strings.APIError.unknownError
        }

        switch message {
        case "USER_NOT_FOUND", "WRONG_PASSWORD":
            return Strings.APIError.loginFailed
        case "USER_ALREADY_EXISTS":
            return Strings.APIError.userAlreadyExists
        default:
            return Strings.APIError.unknownError
        }
    }
}
