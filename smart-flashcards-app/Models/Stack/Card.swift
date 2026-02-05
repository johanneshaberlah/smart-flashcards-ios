import Foundation

struct Card: Codable, Identifiable {
    let id: Int64
    let uniqueId: String
    let question: String
    let answer: String
    let hint: String?
    let maturity: CardMaturity?
    let difficultyAndDurations: [DifficultyAndDuration]?
}
