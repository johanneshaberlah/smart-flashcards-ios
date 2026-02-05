import Foundation

struct CardRatingRequest: Codable {
    let stackId: String
    let cardId: String
    let difficultyId: Int64
}
