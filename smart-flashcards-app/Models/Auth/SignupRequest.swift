import Foundation

struct SignupRequest: Encodable {
    let name: String
    let mail: String
    let password: String
}
