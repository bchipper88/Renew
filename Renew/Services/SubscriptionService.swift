import Combine
import Foundation

final class SubscriptionService {
    private let statusSubject: CurrentValueSubject<SubscriptionStatus, Never>
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        self.statusSubject = CurrentValueSubject(.trial(daysRemaining: 3))
    }

    var subscriptionPublisher: AnyPublisher<SubscriptionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    @MainActor
    func startTrial() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        statusSubject.send(.trial(daysRemaining: 3))
    }

    @MainActor
    func refreshStatus() async {
        statusSubject.send(statusSubject.value)
    }
}
