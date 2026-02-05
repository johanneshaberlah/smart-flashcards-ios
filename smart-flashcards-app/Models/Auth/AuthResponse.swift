import Foundation

struct AuthResponse: Decodable {
    let token: String
    let username: String
}
