import UserNotifications

final class NotificationScheduler {
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else { throw NotificationError.authorizationDenied }
        try await scheduleCoreReminders(center: center)
    }

    private func scheduleCoreReminders(center: UNUserNotificationCenter) async throws {
        let templates = NotificationTemplate.allCases
        for template in templates {
            let content = UNMutableNotificationContent()
            content.title = template.title
            content.body = template.body
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = template.hour
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: template.identifier, content: content, trigger: trigger)
            try await center.add(request)
        }
    }
}

enum NotificationTemplate: CaseIterable {
    case morning, midday, afternoon, evening

    var identifier: String {
        switch self {
        case .morning: return "renew.morning"
        case .midday: return "renew.midday"
        case .afternoon: return "renew.afternoon"
        case .evening: return "renew.evening"
        }
    }

    var hour: Int {
        switch self {
        case .morning: return 8
        case .midday: return 12
        case .afternoon: return 16
        case .evening: return 20
        }
    }

    var title: String {
        switch self {
        case .morning: return "Start with Intention"
        case .midday: return "Midday Reset"
        case .afternoon: return "Step Outside"
        case .evening: return "Shutdown Ritual"
        }
    }

    var body: String {
        switch self {
        case .morning: return "Track your sleep & set your Core 4 focus today."
        case .midday: return "Take a 3-minute reset — stand, breathe, seek sunlight."
        case .afternoon: return "Step outside for 15 minutes of sunlight ☀️"
        case .evening: return "Shutdown with gratitude — what gave you purpose?"
        }
    }
}

enum NotificationError: LocalizedError {
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Notifications are required to stay on track. You can enable them in Settings."
        }
    }
}
