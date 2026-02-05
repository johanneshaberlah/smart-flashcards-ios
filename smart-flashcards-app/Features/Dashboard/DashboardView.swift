import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacing6) {
                Spacer()

                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Theme.emerald600)

                if let username = appState.username {
                    Text(String(format: Strings.Dashboard.welcomeUser, username))
                        .font(.title2)
                        .foregroundStyle(Theme.gray600)
                }

                Text("Deine Stapel werden hier angezeigt")
                    .font(.body)
                    .foregroundStyle(Theme.gray600)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(Strings.Dashboard.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.Dashboard.logout) {
                        appState.logout()
                    }
                    .foregroundStyle(Theme.emerald600)
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
