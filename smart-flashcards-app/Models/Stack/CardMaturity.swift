import Foundation

struct CardMaturity: Codable, Identifiable {
    let id: Int64
    let maturityTimestamp: String
    let level: Int
}
