import SwiftUI

struct StackListView: View {
    @State private var viewModel = StackListViewModel()
    @State private var showCreateSheet = false
    @State private var stackToDelete: Stack?

    var body: some View {
        ZStack {
            // List always exists - just hidden when empty to prevent UICollectionView crash
            stackListView
                .opacity(viewModel.stacks.isEmpty && !viewModel.isLoading ? 0 : 1)

            // Overlay states on top
            if viewModel.isLoading && viewModel.stacks.isEmpty {
                loadingView
            } else if viewModel.stacks.isEmpty {
                emptyStateView
            }
        }
        .navigationTitle(Strings.Stack.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(Strings.Stack.create) {
                    showCreateSheet = true
                }
                .foregroundStyle(Theme.emerald600)
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateStackView { stack in
                viewModel.addStack(stack)
            }
        }
        .alert(
            Strings.Stack.deleteTitle,
            isPresented: Binding(
                get: { stackToDelete != nil },
                set: { if !$0 { stackToDelete = nil } }
            ),
            presenting: stackToDelete
        ) { stack in
            Button(Strings.Stack.cancel, role: .cancel) { }
            Button(Strings.Stack.deleteConfirm, role: .destructive) {
                Task {
                    await viewModel.deleteStack(stack)
                }
            }
        } message: { stack in
            Text(String(format: Strings.Stack.deleteMessage, stack.name))
        }
        .task {
            await viewModel.loadStacks()
        }
    }

    private var loadingView: some View {
        VStack(spacing: Theme.spacing6) {
            Spacer()
            ProgressView()
            Text(Strings.Stack.loading)
                .font(.body)
                .foregroundStyle(Theme.gray600)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: Theme.spacing6) {
            Spacer()

            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.emerald600)

            Text(Strings.Stack.emptyState)
                .font(.body)
                .foregroundStyle(Theme.gray600)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .refreshable {
            await viewModel.loadStacks()
        }
    }

    private var stackListView: some View {
        List {
            ForEach(viewModel.stacks, id: \.uniqueId) { stack in
                StackRowView(stack: stack)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            stackToDelete = stack
                        } label: {
                            Label(Strings.Stack.deleteConfirm, systemImage: "trash")
                        }
                    }
            }
        }
        .contentMargins(.top, Theme.spacing4, for: .scrollContent)
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadStacks()
        }
    }
}

#Preview {
    NavigationStack {
        StackListView()
    }
}
