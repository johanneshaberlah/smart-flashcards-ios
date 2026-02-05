import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            StackListView()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(Strings.Dashboard.logout) {
                            appState.logout()
                        }
                        .foregroundStyle(Theme.gray600)
                    }
                }
        }
    }
}

#Preview {
    let appState = AppState()
    appState.login(token: "test", username: "Max")
    return DashboardView()
        .environment(appState)
}
