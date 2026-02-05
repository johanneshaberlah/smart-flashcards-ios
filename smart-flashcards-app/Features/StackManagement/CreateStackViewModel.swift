import Foundation
import SwiftUI
import UIKit

@Observable
final class CreateStackViewModel {
    var name: String = ""
    var color: Color = Color(hex: "#059669")
    var isLoading: Bool = false
    var errorMessage: String?

    func validate() -> Bool {
        errorMessage = nil

        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = Strings.Stack.emptyName
            triggerErrorHaptic()
            return false
        }

        return true
    }

    func createStack() async throws -> Stack {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let stack = try await StackService.createStack(
                name: name.trimmingCharacters(in: .whitespaces),
                color: color.hexString
            )
            triggerSuccessHaptic()
            return stack
        } catch let error as APIError {
            print("[CreateStackViewModel] Create error: \(error)")
            errorMessage = error.userMessage
            triggerErrorHaptic()
            throw error
        } catch {
            print("[CreateStackViewModel] Create unknown error: \(error)")
            errorMessage = Strings.Stack.createError
            triggerErrorHaptic()
            throw error
        }
    }

    func clearForm() {
        name = ""
        color = Color(hex: "#059669")
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
