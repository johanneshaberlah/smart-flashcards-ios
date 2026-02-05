import SwiftUI

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CardDetailViewModel
    @State private var showDeleteConfirmation = false

    let stackId: String
    var onCardSaved: ((Card) -> Void)?
    var onCardDeleted: (() -> Void)?

    init(stackId: String, card: Card? = nil, onCardSaved: ((Card) -> Void)? = nil, onCardDeleted: (() -> Void)? = nil) {
        self.stackId = stackId
        self.onCardSaved = onCardSaved
        self.onCardDeleted = onCardDeleted

        let mode: CardDetailMode = card.map { .edit($0) } ?? .create
        self._viewModel = State(initialValue: CardDetailViewModel(stackId: stackId, mode: mode))
    }

    var body: some View {
        NavigationStack {
            Form {
                questionSection
                answerSection

                if let errorMessage = viewModel.errorMessage {
                    errorSection(errorMessage)
                }
            }
            .navigationTitle(viewModel.isEditMode ? Strings.Card.editCard : Strings.Card.createCard)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .alert(
                Strings.Card.deleteTitle,
                isPresented: $showDeleteConfirmation
            ) {
                Button(Strings.Stack.cancel, role: .cancel) { }
                Button(Strings.Card.deleteConfirm, role: .destructive) {
                    deleteCard()
                }
            } message: {
                Text(Strings.Card.deleteMessage)
            }
            .interactiveDismissDisabled(viewModel.isLoading)
        }
    }

    // MARK: - Sections

    private var questionSection: some View {
        Section(Strings.Card.question) {
            TextField(Strings.Card.questionPlaceholder, text: $viewModel.question, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var answerSection: some View {
        Section(Strings.Card.answer) {
            TextEditor(text: $viewModel.answer)
                .frame(minHeight: 150)
        }
    }

    private func errorSection(_ message: String) -> some View {
        Section {
            Text(message)
                .foregroundStyle(Theme.errorText)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                cancelButton

                if viewModel.isEditMode {
                    deleteButton
                }

                Spacer()

                saveButton
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
        .disabled(viewModel.isLoading)
    }

    private var deleteButton: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.tint(Theme.red500).interactive(), in: .circle)
        .disabled(viewModel.isLoading)
    }

    private var saveButton: some View {
        Button {
            saveCard()
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(width: 44, height: 44)
            } else {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .glassEffect(.regular.tint(Theme.emerald600).interactive(), in: .circle)
        .disabled(viewModel.isLoading)
    }

    // MARK: - Actions

    private func saveCard() {
        guard viewModel.validate() else { return }

        Task {
            do {
                let card = try await viewModel.save()
                onCardSaved?(card)
                dismiss()
            } catch {
                // Error is handled in viewModel
            }
        }
    }

    private func deleteCard() {
        Task {
            do {
                try await viewModel.delete()
                onCardDeleted?()
                dismiss()
            } catch {
                // Error is handled in viewModel
            }
        }
    }
}

#Preview("Create Mode") {
    CardDetailView(stackId: "stack-1") { card in
        print("Card saved: \(card.question)")
    }
}

#Preview("Edit Mode") {
    CardDetailView(
        stackId: "stack-1",
        card: Card(
            id: 1,
            uniqueId: "card-1",
            question: "What is photosynthesis?",
            answer: "The process by which plants convert light energy into chemical energy",
            hint: nil,
            maturity: nil,
            difficultyAndDurations: nil
        )
    ) { card in
        print("Card updated: \(card.question)")
    } onCardDeleted: {
        print("Card deleted")
    }
}
