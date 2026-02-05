import Foundation

struct DeleteCardRequest: Codable {
    let stackId: String
    let cardId: String
    let question: String
    let answer: String
}
