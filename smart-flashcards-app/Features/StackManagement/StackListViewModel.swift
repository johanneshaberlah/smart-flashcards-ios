import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class StackListViewModel {
    var stacks: [Stack] = []
    var isLoading: Bool = false
    var errorMessage: String?

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

    func deleteStack(_ stack: Stack) async {
        guard let index = stacks.firstIndex(where: { $0.uniqueId == stack.uniqueId }) else {
            return
        }

        let deletedStack = stacks[index]

        withAnimation {
            stacks.remove(at: index)
        }

        do {
            try await StackService.deleteStack(uniqueId: stack.uniqueId)
            triggerSuccessHaptic()
        } catch let error as APIError {
            print("[StackListViewModel] Delete error: \(error)")
            withAnimation {
                stacks.insert(deletedStack, at: min(index, stacks.count))
            }
            errorMessage = error.userMessage
            triggerErrorHaptic()
        } catch {
            print("[StackListViewModel] Delete unknown error: \(error)")
            withAnimation {
                stacks.insert(deletedStack, at: min(index, stacks.count))
            }
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
