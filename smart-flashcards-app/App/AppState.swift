import Foundation
import SwiftUI

@Observable
final class AppState {
    var isAuthenticated: Bool = false
    var username: String?

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        if let token = KeychainService.getToken(), !token.isEmpty {
            isAuthenticated = true
            username = UserDefaultsService.username
        } else {
            isAuthenticated = false
            username = nil
        }
    }

    func login(token: String, username: String) {
        _ = KeychainService.saveToken(token)
        UserDefaultsService.username = username
        self.username = username
        isAuthenticated = true
    }

    func logout() {
        _ = KeychainService.deleteToken()
        UserDefaultsService.clear()
        username = nil
        isAuthenticated = false
    }
}
