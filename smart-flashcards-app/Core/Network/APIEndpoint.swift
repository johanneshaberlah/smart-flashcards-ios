import Foundation

enum APIEndpoint {
    case login
    case signup
    case stacks
    case createStack
    case deleteStack(uniqueId: String)
    case stack(uniqueId: String)
    case createCard
    case updateCard(stackId: String, cardId: String)
    case deleteCard(stackId: String, cardId: String)
    case createFromFile(stackId: String)
    case nextCard(stackId: String, daysAhead: Int)
    case submitRating

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
        case .stack(let uniqueId):
            return "/stack/\(uniqueId)"
        case .createCard:
            return "/card"
        case .updateCard(let stackId, let cardId):
            return "/stack/\(stackId)/card/\(cardId)"
        case .deleteCard(let stackId, let cardId):
            return "/stack/\(stackId)/card/\(cardId)"
        case .createFromFile(let stackId):
            return "/stack/\(stackId)/createFromFile"
        case .nextCard(let stackId, let daysAhead):
            return "/stack/\(stackId)/card/next?days-ahead=\(daysAhead)"
        case .submitRating:
            return "/stack/rating"
        }
    }

    var url: URL? {
        URL(string: Self.baseURL + path)
    }

    var method: String {
        switch self {
        case .login, .signup, .createStack, .createCard, .createFromFile, .submitRating:
            return "POST"
        case .stacks, .stack, .nextCard:
            return "GET"
        case .updateCard:
            return "PUT"
        case .deleteStack, .deleteCard:
            return "DELETE"
        }
    }
}
