import Combine
import Foundation

final class AppState: ObservableObject {
    @Published var session: AuthSession?
    @Published var profile: UserProfile?
    @Published var subscriptionStatus: SubscriptionStatus = .trial(daysRemaining: 3)
    @Published var onboardingCompleted: Bool = false

    var isSignedIn: Bool {
        session != nil
    }

    var shouldShowOnboarding: Bool {
        isSignedIn && !onboardingCompleted
    }
}
