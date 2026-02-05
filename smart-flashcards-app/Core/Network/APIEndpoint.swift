import Foundation

enum APIEndpoint {
    case login
    case signup

    private static let baseURL = "https://api.smart-flashcards.com"

    var path: String {
        switch self {
        case .login:
            return "/login"
        case .signup:
            return "/signup"
        }
    }

    var url: URL? {
        URL(string: Self.baseURL + path)
    }

    var method: String {
        switch self {
        case .login, .signup:
            return "POST"
        }
    }
}
