import Combine
import OSLog
import Foundation

final class AppEnvironment: ObservableObject {
    let container: AppContainer
    let state: AppState

    private var cancellables: Set<AnyCancellable> = []

    init(container: AppContainer = AppContainer(), state: AppState = AppState()) {
        self.container = container
        self.state = state
        AppLogger.app.debug("AppEnvironment initialized")
        bindAuthState()
        bindSubscriptionState()
    }

    private func bindAuthState() {
        container.authService.sessionPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { session in
                if let session = session {
                    AppLogger.auth.debug("Received session: \(session.userID.uuidString)")
                } else {
                    AppLogger.auth.debug("Session cleared")
                }
            })
            .assign(to: &state.$session)

        container.authService.profilePublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { profile in
                if let profile = profile {
                    AppLogger.auth.debug("Loaded profile for: \(profile.email)")
                } else {
                    AppLogger.auth.debug("Profile cleared")
                }
            })
            .assign(to: &state.$profile)
    }

    private func bindSubscriptionState() {
        container.subscriptionService.subscriptionPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { status in
                AppLogger.app.debug("Subscription status changed: \(String(describing: status))")
            })
            .assign(to: &state.$subscriptionStatus)
    }
}
