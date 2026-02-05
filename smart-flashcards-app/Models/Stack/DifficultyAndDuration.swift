import Foundation

struct DifficultyAndDuration: Codable, Identifiable {
    let difficulty: Difficulty
    let duration: Duration

    var id: Int64 {
        difficulty.id
    }
}
