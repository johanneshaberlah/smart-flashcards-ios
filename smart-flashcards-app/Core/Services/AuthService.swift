import Foundation

enum AuthService {
    static func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(mail: email, password: password)
        return try await APIClient.shared.request(
            endpoint: .login,
            body: request
        )
    }

    static func signup(name: String, email: String, password: String) async throws -> AuthResponse {
        let request = SignupRequest(name: name, mail: email, password: password)
        return try await APIClient.shared.request(
            endpoint: .signup,
            body: request
        )
    }
}
