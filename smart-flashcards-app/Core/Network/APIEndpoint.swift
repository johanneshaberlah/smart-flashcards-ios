import Foundation

enum APIEndpoint {
    case login
    case signup
    case stacks
    case createStack
    case deleteStack(uniqueId: String)

    private static let baseURL = "https://api.smart-flashcards.com"

    var path: String {
        switch self {
        case .login:
            return "/login"
        case .signup:
            return "/signup"
        case .stacks, .createStack:
            return "/stack"
        case .deleteStack(let uniqueId):
            return "/stack/\(uniqueId)"
        }
    }

    var url: URL? {
        URL(string: Self.baseURL + path)
    }

    var method: String {
        switch self {
        case .login, .signup, .createStack:
            return "POST"
        case .stacks:
            return "GET"
        case .deleteStack:
            return "DELETE"
        }
    }
}
