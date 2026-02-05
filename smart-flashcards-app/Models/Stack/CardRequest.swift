import Foundation

struct CardRequest: Codable {
    let stackId: String
    let cardId: String?
    let question: String
    let answer: String
}
