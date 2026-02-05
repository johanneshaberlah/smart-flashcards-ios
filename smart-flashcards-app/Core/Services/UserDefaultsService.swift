import Foundation

enum UserDefaultsService {
    private static let usernameKey = "username"

    static var username: String? {
        get {
            UserDefaults.standard.string(forKey: usernameKey)
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: usernameKey)
            } else {
                UserDefaults.standard.removeObject(forKey: usernameKey)
            }
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: usernameKey)
    }
}
