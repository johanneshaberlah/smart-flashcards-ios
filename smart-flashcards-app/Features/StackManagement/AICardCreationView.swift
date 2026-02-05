import SwiftUI
import UniformTypeIdentifiers

struct AICardCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AICardCreationViewModel
    @State private var showFileImporter = false

    var onCompletion: (() -> Void)?

    init(stackId: String, onCompletion: (() -> Void)? = nil) {
        self._viewModel = State(initialValue: AICardCreationViewModel(stackId: stackId))
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else {
                    formContent
                }
            }
            .navigationTitle(Strings.AICardCreation.title)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if !viewModel.isLoading {
                    bottomBar
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let url = urls.first {
                    viewModel.handleFileSelection(.success(url))
                } else if case .failure(let error) = result {
                    viewModel.handleFileSelection(.failure(error))
                }
            }
            .interactiveDismissDisabled(viewModel.isLoading)
        }
    }

    // MARK: - Form Content

    private var formContent: some View {
        Form {
            fileSection
            instructionsSection

            if let errorMessage = viewModel.errorMessage {
                errorSection(errorMessage)
            }
        }
    }

    private var fileSection: some View {
        Section {
            if let fileName = viewModel.selectedFileName {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(Theme.emerald600)
                    Text(fileName)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        viewModel.clearFile()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.gray300)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button {
                    showFileImporter = true
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .foregroundStyle(Theme.emerald600)
                        Text(Strings.AICardCreation.selectFile)
                            .foregroundStyle(Theme.gray600)
                    }
                }
            }
        } header: {
            Text(Strings.AICardCreation.fileSection)
        } footer: {
            Text(Strings.AICardCreation.fileHint)
        }
    }

    private var instructionsSection: some View {
        Section(Strings.AICardCreation.instructionsSection) {
            TextField(
                Strings.AICardCreation.instructionsPlaceholder,
                text: $viewModel.customInstructions,
                axis: .vertical
            )
            .lineLimit(3...5)
        }
    }

    private func errorSection(_ message: String) -> some View {
        Section {
            Text(message)
                .foregroundStyle(Theme.errorText)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 70))
                .foregroundStyle(Theme.amber500)
                .symbolEffect(.bounce.byLayer, options: .repeating)

            Text(viewModel.currentProgressMessage)
                .font(.body)
                .foregroundStyle(Theme.gray600)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentProgressMessage)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                cancelButton
                Spacer()
                generateButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.tint(Theme.gray600).interactive(), in: .circle)
    }

    private var generateButton: some View {
        Button {
            uploadFile()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                Text(Strings.AICardCreation.generate)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .glassEffect(.regular.tint(Theme.amber500).interactive())
        .disabled(!viewModel.hasSelectedFile)
        .opacity(viewModel.hasSelectedFile ? 1.0 : 0.5)
    }

    // MARK: - Actions

    private func uploadFile() {
        Task {
            do {
                try await viewModel.upload()
                onCompletion?()
                dismiss()
            } catch {
                // Error is handled in viewModel
            }
        }
    }
}

#Preview {
    AICardCreationView(stackId: "stack-1") {
        print("Completed")
    }
}
