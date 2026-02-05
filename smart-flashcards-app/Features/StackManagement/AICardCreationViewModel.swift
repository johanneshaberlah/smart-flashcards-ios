import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class AICardCreationViewModel {
    var customInstructions: String = ""
    var selectedFileName: String?
    var isLoading = false
    var errorMessage: String?
    var currentProgressMessage: String = Strings.AICardCreation.progressImporting

    private var selectedFileData: Data?
    private static let maxFileSizeBytes = 10 * 1024 * 1024 // 10 MB

    private static let progressMessages: [(delay: TimeInterval, message: String)] = [
        (0, Strings.AICardCreation.progressImporting),
        (5, Strings.AICardCreation.progressChecking),
        (12, Strings.AICardCreation.progressUploading),
        (19, Strings.AICardCreation.progressProviding),
        (35, Strings.AICardCreation.progressGenerating),
        (45, Strings.AICardCreation.progressStillGenerating),
        (50, Strings.AICardCreation.progressUpdating),
        (60, Strings.AICardCreation.progressAlmostDone)
    ]

    private let stackId: String
    private var progressTimer: Timer?
    private var progressStartTime: Date?

    init(stackId: String) {
        self.stackId = stackId
    }

    func handleFileSelection(_ result: Result<URL, Error>) {
        errorMessage = nil

        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = Strings.AICardCreation.fileReadError
                triggerErrorHaptic()
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let fileData = try Data(contentsOf: url)

                if fileData.count > Self.maxFileSizeBytes {
                    errorMessage = Strings.AICardCreation.fileTooLarge
                    triggerErrorHaptic()
                    return
                }

                selectedFileData = fileData
                selectedFileName = url.lastPathComponent
            } catch {
                print("[AICardCreationViewModel] File read error: \(error)")
                errorMessage = Strings.AICardCreation.fileReadError
                triggerErrorHaptic()
            }

        case .failure(let error):
            print("[AICardCreationViewModel] File selection error: \(error)")
            errorMessage = Strings.AICardCreation.fileReadError
            triggerErrorHaptic()
        }
    }

    func clearFile() {
        selectedFileData = nil
        selectedFileName = nil
        errorMessage = nil
    }

    var hasSelectedFile: Bool {
        selectedFileData != nil
    }

    func upload() async throws {
        guard let pdfData = selectedFileData else {
            errorMessage = Strings.AICardCreation.noFileSelected
            triggerErrorHaptic()
            return
        }

        isLoading = true
        errorMessage = nil
        startProgressMessages()
        defer {
            isLoading = false
            stopProgressMessages()
        }

        do {
            let filename = selectedFileName ?? "document.pdf"

            try await StackService.createCardsFromFile(
                stackId: stackId,
                pdfData: pdfData,
                filename: filename,
                customInstructions: customInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            triggerSuccessHaptic()
        } catch let error as APIError {
            print("[AICardCreationViewModel] Upload error: \(error)")
            errorMessage = error.userMessage
            triggerErrorHaptic()
            throw error
        } catch {
            print("[AICardCreationViewModel] Upload unknown error: \(error)")
            errorMessage = Strings.AICardCreation.uploadError
            triggerErrorHaptic()
            throw error
        }
    }

    private func startProgressMessages() {
        currentProgressMessage = Strings.AICardCreation.progressImporting
        progressStartTime = Date()

        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgressMessage()
            }
        }
    }

    private func stopProgressMessages() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressStartTime = nil
    }

    private func updateProgressMessage() {
        guard let startTime = progressStartTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)

        for (index, item) in Self.progressMessages.enumerated().reversed() {
            if elapsed >= item.delay {
                if index + 1 < Self.progressMessages.count {
                    let nextDelay = Self.progressMessages[index + 1].delay
                    if elapsed < nextDelay {
                        currentProgressMessage = item.message
                        return
                    }
                } else {
                    currentProgressMessage = item.message
                    return
                }
            }
        }
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
