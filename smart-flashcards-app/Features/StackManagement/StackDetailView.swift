import SwiftUI

enum CardDetailSheetItem: Identifiable {
    case create
    case edit(Card)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let card): return card.uniqueId
        }
    }

    var card: Card? {
        switch self {
        case .create: return nil
        case .edit(let card): return card
        }
    }
}

struct StackDetailView: View {
    let stack: Stack

    @State private var viewModel: StackDetailViewModel
    @State private var cardToDelete: Card?
    @State private var cardDetailSheet: CardDetailSheetItem?
    @State private var showAICardCreation = false
    @State private var showLearningSession = false

    init(stack: Stack) {
        self.stack = stack
        self._viewModel = State(initialValue: StackDetailViewModel(stack: stack))
    }

    var body: some View {
        ZStack {
            cardListView
                .opacity(viewModel.cards.isEmpty && !viewModel.isLoading ? 0 : 1)

            if viewModel.isLoading && viewModel.cards.isEmpty {
                loadingView
            } else if viewModel.cards.isEmpty {
                emptyStateView
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomNavigationBar
        }
        .navigationTitle(stack.name)
        .alert(
            Strings.Card.deleteTitle,
            isPresented: Binding(
                get: { cardToDelete != nil },
                set: { if !$0 { cardToDelete = nil } }
            ),
            presenting: cardToDelete
        ) { card in
            Button(Strings.Stack.cancel, role: .cancel) { }
            Button(Strings.Card.deleteConfirm, role: .destructive) {
                Task {
                    await viewModel.deleteCard(card)
                }
            }
        } message: { _ in
            Text(Strings.Card.deleteMessage)
        }
        .task {
            await viewModel.loadStack()
        }
        .sheet(item: $cardDetailSheet) { item in
            CardDetailView(
                stackId: stack.uniqueId,
                card: item.card,
                onCardSaved: { card in
                    if case .edit = item {
                        // Update existing card
                        if let index = viewModel.cards.firstIndex(where: { $0.uniqueId == card.uniqueId }) {
                            viewModel.cards[index] = card
                        }
                    } else {
                        // Add new card
                        viewModel.cards.insert(card, at: 0)
                    }
                },
                onCardDeleted: {
                    if case .edit(let editedCard) = item,
                       let index = viewModel.cards.firstIndex(where: { $0.uniqueId == editedCard.uniqueId }) {
                        viewModel.cards.remove(at: index)
                    }
                }
            )
        }
        .fullScreenCover(isPresented: $showLearningSession) {
            LearningView(stackId: stack.uniqueId) {
                showLearningSession = false
                Task {
                    await viewModel.loadStack()
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: Theme.spacing6) {
            Spacer()
            ProgressView()
            Text(Strings.Stack.loading)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: Theme.spacing6) {
            Spacer()

            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundStyle(Theme.emerald600)

            Text(Strings.Card.emptyState)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .refreshable {
            await viewModel.loadStack()
        }
    }

    private var cardListView: some View {
        List {
            ForEach(viewModel.cards, id: \.uniqueId) { card in
                CardRowView(card: card)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        cardDetailSheet = .edit(card)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            cardToDelete = card
                        } label: {
                            Label(Strings.Card.deleteConfirm, systemImage: "trash")
                        }
                    }
            }
        }
        .contentMargins(.top, Theme.spacing4, for: .scrollContent)
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadStack()
        }
    }

    private var bottomNavigationBar: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                startLearningButton

                Spacer()

                createCardButton
                autoCreateButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var startLearningButton: some View {
        Button {
            showLearningSession = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "play.fill")
                Text(Strings.Card.startLearning)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .glassEffect(.regular.tint(Theme.emerald600).interactive())
    }

    private var createCardButton: some View {
        Button {
            cardDetailSheet = .create
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.tint(Theme.emerald600).interactive(), in: .circle)
    }

    private var autoCreateButton: some View {
        Button {
            showAICardCreation = true
        } label: {
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.tint(Theme.amber500).interactive(), in: .circle)
        .sheet(isPresented: $showAICardCreation) {
            AICardCreationView(stackId: stack.uniqueId) {
                Task {
                    await viewModel.loadStack()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StackDetailView(stack: Stack(
            id: 1,
            uniqueId: "stack-1",
            name: "Biology",
            color: "#10B981",
            cards: [
                Card(
                    id: 1,
                    uniqueId: "card-1",
                    question: "What is photosynthesis?",
                    answer: "The process by which plants convert light energy",
                    hint: nil,
                    maturity: CardMaturity(id: 1, maturity: "2026-02-15T10:00:00Z", level: 1),
                    difficultyAndDurations: nil
                ),
                Card(
                    id: 2,
                    uniqueId: "card-2",
                    question: "What is mitosis?",
                    answer: "Cell division resulting in two identical daughter cells",
                    hint: nil,
                    maturity: nil,
                    difficultyAndDurations: nil
                )
            ]
        ))
    }
}
