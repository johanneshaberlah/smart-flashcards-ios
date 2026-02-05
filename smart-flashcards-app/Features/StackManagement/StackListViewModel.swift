import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class StackListViewModel {
    var stacks: [Stack] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var stackToDelete: Stack?

    func loadStacks() async {
        isLoading = true
        errorMessage = nil

        do {
            stacks = try await StackService.fetchStacks()
        } catch let error as APIError {
            print("[StackListViewModel] Load error: \(error)")
            errorMessage = error.userMessage
            triggerErrorHaptic()
        } catch {
            print("[StackListViewModel] Load unknown error: \(error)")
            errorMessage = Strings.Stack.loadError
            triggerErrorHaptic()
        }

        isLoading = false
    }

    func confirmDelete(stack: Stack) {
        stackToDelete = stack
    }

    func deleteStack(_ stack: Stack) async {
        do {
            try await StackService.deleteStack(uniqueId: stack.uniqueId)
            stackToDelete = nil
            withAnimation {
                stacks.removeAll { $0.uniqueId == stack.uniqueId }
            }
            triggerSuccessHaptic()
        } catch let error as APIError {
            print("[StackListViewModel] Delete error: \(error)")
            errorMessage = error.userMessage
            triggerErrorHaptic()
        } catch {
            print("[StackListViewModel] Delete unknown error: \(error)")
            errorMessage = Strings.Stack.deleteError
            triggerErrorHaptic()
        }
    }

    func addStack(_ stack: Stack) {
        stacks.append(stack)
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
