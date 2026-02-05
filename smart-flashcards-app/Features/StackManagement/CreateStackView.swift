import SwiftUI

struct CreateStackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CreateStackViewModel()

    var onStackCreated: (Stack) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(Strings.Stack.namePlaceholder, text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                }

                Section(Strings.Stack.color) {
                    ColorPicker(Strings.Stack.color, selection: $viewModel.color, supportsOpacity: false)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(Strings.Stack.create)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Stack.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button(Strings.Stack.save) {
                            saveStack()
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.emerald600)
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.isLoading)
        }
    }

    private func saveStack() {
        guard viewModel.validate() else { return }

        Task {
            do {
                let stack = try await viewModel.createStack()
                onStackCreated(stack)
                dismiss()
            } catch {
                // Error is handled in viewModel
            }
        }
    }
}

#Preview {
    CreateStackView { stack in
        print("Created stack: \(stack.name)")
    }
}
