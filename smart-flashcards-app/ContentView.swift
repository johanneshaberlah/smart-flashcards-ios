import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                DashboardView()
            } else {
                OnboardingView()
            }
        }
        .animation(.default, value: appState.isAuthenticated)
    }
}

#Preview("Logged Out") {
    ContentView()
        .environment(AppState())
}

#Preview("Logged In") {
    let appState = AppState()
    appState.login(token: "test", username: "Max")
    return ContentView()
        .environment(appState)
}
