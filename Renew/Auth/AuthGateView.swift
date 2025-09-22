import SwiftUI
import OSLog

struct AuthGateView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var state: AppState
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            VStack(spacing: 8) {
                Text("Renew")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(
                        colors: [.blue, .teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                Text("Recover from burnout with daily Core 4 wins")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            VStack(spacing: 16) {
                Button(action: { viewModel.signInWithApple(container: container) }) {
                    Label("Continue with Apple", systemImage: "apple.logo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RenewButtonStyle(style: .primary))

                Button(action: { viewModel.signInWithMagicLink(container: container) }) {
                    Label("Email me a magic link", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RenewButtonStyle(style: .glass))
            }
            .padding(.horizontal)

            if let message = viewModel.statusMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Text("3-day premium trial when you sign in")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .padding()
        .background(GradientBackground())
        .onAppear {
            AppLogger.auth.debug("AuthGateView appeared")
        }
        .task {
            await viewModel.bootstrap(container: container)
        }
        .overlay(alignment: .topTrailing) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
            }
        }
    }
}

final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var statusMessage: String?

    func bootstrap(container: AppContainer) async {
        guard !isLoading else { return }
        isLoading = true
        AppLogger.auth.debug("Restoring session")
        defer {
            self.isLoading = false
            AppLogger.auth.debug("Finished restoreSession isLoading=\(self.isLoading)")
        }
        await container.authService.restoreSession()
    }

    func signInWithApple(container: AppContainer) {
        Task { await authenticate(using: { try await container.authService.signInWithApple() }, label: "SignInWithApple") }
    }

    func signInWithMagicLink(container: AppContainer) {
        Task { await authenticate(using: { try await container.authService.signInWithMagicLink(email: "founder@renew.app") }, label: "MagicLink") }
    }

    @MainActor
    private func authenticate(using action: @escaping () async throws -> Void, label: String) async {
        isLoading = true
        statusMessage = "Signing in..."
        AppLogger.auth.debug("Auth flow started: \(label)")
        defer {
            isLoading = false
            AppLogger.auth.debug("Auth flow finished: \(label)")
        }
        do {
            try await action()
            statusMessage = "Signed in successfully"
        } catch {
            statusMessage = "Failed to sign in: \(error.localizedDescription)"
            AppLogger.auth.error("Auth flow error: \(label): \(error.localizedDescription)")
        }
    }
}
