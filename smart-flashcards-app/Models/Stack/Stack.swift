import Foundation

struct Stack: Codable, Identifiable {
    let id: Int64
    let uniqueId: String
    let name: String
    let color: String
    let cards: [Card]
}
