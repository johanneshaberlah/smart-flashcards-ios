import Foundation

struct LoginRequest: Encodable {
    let mail: String
    let password: String
}
