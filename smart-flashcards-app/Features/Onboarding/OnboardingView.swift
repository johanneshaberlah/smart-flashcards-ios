import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = OnboardingViewModel()
    @State private var mode: OnboardingMode = .login
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case email
        case password
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                segmentedControl
                formSection
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image("smart flashcards brain (1024)")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Text(Strings.Onboarding.welcome)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .padding(.top, 60)
        .padding(.bottom, Theme.spacing6)
    }

    private var segmentedControl: some View {
        Picker("", selection: $mode) {
            Text(Strings.Onboarding.login).tag(OnboardingMode.login)
            Text(Strings.Onboarding.register).tag(OnboardingMode.register)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Theme.spacing4)
        .padding(.bottom, Theme.spacing4)
        .onChange(of: mode) {
            viewModel.errorMessage = nil
        }
    }

    private var formSection: some View {
        Form {
            if mode == .register {
                Section {
                    TextField(Strings.Onboarding.name, text: $viewModel.name)
                        .focused($focusedField, equals: .name)
                        .textContentType(.name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                }
            }

            Section {
                TextField(Strings.Onboarding.email, text: $viewModel.email)
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }

                SecureField(Strings.Onboarding.password, text: $viewModel.password)
                    .focused($focusedField, equals: .password)
                    .textContentType(mode == .login ? .password : .newPassword)
                    .submitLabel(.go)
                    .onSubmit { submit() }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.circle")
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button(action: submit) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(mode == .login ? Strings.Onboarding.login : Strings.Onboarding.register)
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .animation(.default, value: mode)
        .animation(.default, value: viewModel.errorMessage)
    }

    private func submit() {
        guard viewModel.validate(mode: mode) else { return }

        focusedField = nil

        Task {
            do {
                let response: AuthResponse
                if mode == .login {
                    response = try await viewModel.login()
                } else {
                    response = try await viewModel.register()
                }
                appState.login(token: response.token, username: response.username)
            } catch {
                // Error is already handled in viewModel
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
