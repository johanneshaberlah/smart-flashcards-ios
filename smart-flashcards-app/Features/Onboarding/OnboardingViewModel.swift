import Foundation
import UIKit

@Observable
final class OnboardingViewModel {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    func validate(mode: OnboardingMode) -> Bool {
        errorMessage = nil

        if mode == .register && name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = Strings.Onboarding.emptyName
            triggerErrorHaptic()
            return false
        }

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = Strings.Onboarding.emptyEmail
            triggerErrorHaptic()
            return false
        }

        if password.isEmpty {
            errorMessage = Strings.Onboarding.emptyPassword
            triggerErrorHaptic()
            return false
        }

        return true
    }

    func login() async throws -> AuthResponse {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await AuthService.login(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            triggerSuccessHaptic()
            return response
        } catch let error as APIError {
            print("[OnboardingViewModel] Login APIError caught: \(error)")
            print("[OnboardingViewModel] Error description: \(error.errorDescription ?? "nil")")
            errorMessage = error.userMessage
            triggerErrorHaptic()
            throw error
        } catch {
            print("[OnboardingViewModel] Login unknown error: \(error)")
            print("[OnboardingViewModel] Error type: \(type(of: error))")
            errorMessage = Strings.APIError.unknownError
            triggerErrorHaptic()
            throw error
        }
    }

    func register() async throws -> AuthResponse {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await AuthService.signup(
                name: name.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            triggerSuccessHaptic()
            return response
        } catch let error as APIError {
            print("[OnboardingViewModel] Register APIError caught: \(error)")
            print("[OnboardingViewModel] Error description: \(error.errorDescription ?? "nil")")
            errorMessage = error.userMessage
            triggerErrorHaptic()
            throw error
        } catch {
            print("[OnboardingViewModel] Register unknown error: \(error)")
            print("[OnboardingViewModel] Error type: \(type(of: error))")
            errorMessage = Strings.APIError.unknownError
            triggerErrorHaptic()
            throw error
        }
    }

    func clearForm() {
        name = ""
        email = ""
        password = ""
        errorMessage = nil
    }

    private func triggerErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
