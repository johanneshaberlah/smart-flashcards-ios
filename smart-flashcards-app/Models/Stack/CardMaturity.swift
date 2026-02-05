import Foundation

struct CardMaturity: Codable, Identifiable {
    let id: Int64
    let maturity: String
    let level: Int
}
