import Combine
import OSLog
import Foundation

final class AuthService {
    private let sessionSubject = CurrentValueSubject<AuthSession?, Never>(nil)
    private let profileSubject = CurrentValueSubject<UserProfile?, Never>(nil)

    var sessionPublisher: AnyPublisher<AuthSession?, Never> {
        sessionSubject.eraseToAnyPublisher()
    }

    var profilePublisher: AnyPublisher<UserProfile?, Never> {
        profileSubject.eraseToAnyPublisher()
    }

    @MainActor
    func restoreSession() async {
        AppLogger.auth.debug("AuthService.restoreSession invoked")
        sessionSubject.send(nil)
        profileSubject.send(nil)
    }

    @MainActor
    func signInWithApple() async throws {
        try await mockAuthenticationFlow(provider: "apple")
    }

    @MainActor
    func signInWithMagicLink(email: String) async throws {
        try await mockAuthenticationFlow(provider: "magic_link", email: email)
    }

    @MainActor
    private func mockAuthenticationFlow(provider: String, email: String = "user@example.com") async throws {
        AppLogger.auth.debug("Starting mock auth flow for provider: \(provider)")
        try await Task.sleep(nanoseconds: 500_000_000)
        let session = AuthSession(
            userID: UUID(),
            email: email,
            accessToken: UUID().uuidString,
            refreshToken: UUID().uuidString
        )
        sessionSubject.send(session)
        profileSubject.send(.placeholder)
        AppLogger.auth.debug("Mock auth flow completed for provider: \(provider)")
    }

    @MainActor
    func signOut() {
        AppLogger.auth.debug("Signing out")
        sessionSubject.send(nil)
        profileSubject.send(nil)
    }
}
