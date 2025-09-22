import Foundation

final class AppContainer: ObservableObject {
    let authService: AuthService
    let subscriptionService: SubscriptionService
    let habitService: HabitService
    let journalService: JournalService
    let learningService: LearningService
    let notificationScheduler: NotificationScheduler
    let journeyService: JourneyService

    init(services: ServiceFactory = ServiceFactory()) {
        self.authService = services.authService
        self.subscriptionService = services.subscriptionService
        self.habitService = services.habitService
        self.journalService = services.journalService
        self.learningService = services.learningService
        self.notificationScheduler = services.notificationScheduler
        self.journeyService = services.journeyService
    }
}

struct ServiceFactory {
    let authService: AuthService
    let subscriptionService: SubscriptionService
    let habitService: HabitService
    let journalService: JournalService
    let learningService: LearningService
    let notificationScheduler: NotificationScheduler
    let journeyService: JourneyService

    init() {
        let auth = AuthService()
        self.authService = auth
        self.subscriptionService = SubscriptionService(authService: auth)
        self.habitService = HabitService()
        self.journalService = JournalService()
        self.learningService = LearningService()
        self.notificationScheduler = NotificationScheduler()
        self.journeyService = JourneyService()
    }
}
