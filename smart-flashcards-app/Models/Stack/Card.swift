import Foundation

struct Card: Codable, Identifiable {
    let id: Int64
    let uniqueId: String
    let question: String
    let answer: String
    let hint: String?
    let maturity: CardMaturity?
    let difficultyAndDurations: [DifficultyAndDuration]?

    var cleanedHint: String? {
        guard let hint else { return nil }
        let prefix = "Hinweis:"
        if hint.hasPrefix(prefix) {
            var result = String(hint.dropFirst(prefix.count))
            while result.first?.isWhitespace == true || result.first?.isNewline == true {
                result.removeFirst()
            }
            return result
        }
        return hint
    }
}
