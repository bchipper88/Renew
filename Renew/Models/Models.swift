import Foundation

enum CoreHabitType: String, CaseIterable, Identifiable, Codable {
    case screenTime
    case sunlight
    case steps
    case sleep

    var id: String { rawValue }

    var title: String {
        switch self {
        case .screenTime: return "Screen Time"
        case .sunlight: return "Sunlight"
        case .steps: return "Steps"
        case .sleep: return "Sleep"
        }
    }

    var unit: String {
        switch self {
        case .screenTime: return "min"
        case .sunlight: return "min"
        case .steps: return "steps"
        case .sleep: return "hrs"
        }
    }
}

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var email: String
    var displayName: String
    var avatarImageData: Data?
    var goals: [CoreHabitType]
    var notificationSettings: NotificationSettings
    var subscriptionStatus: SubscriptionStatus

    static let placeholder = UserProfile(
        id: UUID(),
        email: "user@example.com",
        displayName: "Renew Explorer",
        avatarImageData: nil,
        goals: CoreHabitType.allCases,
        notificationSettings: .allEnabled,
        subscriptionStatus: .trial(daysRemaining: 3)
    )
}

enum SubscriptionStatus: Codable, Equatable {
    case trial(daysRemaining: Int)
    case premium(expiration: Date?)
    case expired

    var isEntitled: Bool {
        switch self {
        case .trial(let days):
            return days > 0
        case .premium:
            return true
        case .expired:
            return false
        }
    }

    var trialDaysRemaining: Int? {
        if case let .trial(days) = self { return days }
        return nil
    }
}

struct NotificationSettings: Codable, Equatable {
    var morningReminderEnabled: Bool
    var middayReminderEnabled: Bool
    var afternoonReminderEnabled: Bool
    var eveningReminderEnabled: Bool

    static let allEnabled = NotificationSettings(
        morningReminderEnabled: true,
        middayReminderEnabled: true,
        afternoonReminderEnabled: true,
        eveningReminderEnabled: true
    )
}

struct HabitLog: Identifiable, Codable {
    var id: UUID
    var date: Date
    var metrics: [CoreHabitType: HabitMetric]
    var shutdownDone: Bool

    static func placeholder(date: Date) -> HabitLog {
        HabitLog(
            id: UUID(),
            date: date,
            metrics: [
                .screenTime: HabitMetric(target: 120, progress: 0),
                .sunlight: HabitMetric(target: 15, progress: 0),
                .steps: HabitMetric(target: 10_000, progress: 0),
                .sleep: HabitMetric(target: 7 * 60, progress: 0)
            ],
            shutdownDone: false
        )
    }
}

struct HabitMetric: Codable {
    var target: Double
    var progress: Double

    var completionRatio: Double {
        guard target > 0 else { return 0 }
        return min(progress / target, 1)
    }

    var isComplete: Bool {
        progress >= target
    }
}

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var purposeNote: String
    var gratitudeNote: String
    var moodScore: Int
    var energyScore: Int
    var burnoutScore: Int?

    static func placeholder(date: Date) -> JournalEntry {
        JournalEntry(
            id: UUID(),
            date: date,
            purposeNote: "Helping a teammate unblock their work.",
            gratitudeNote: "Sunshine during lunch.",
            moodScore: 3,
            energyScore: 7,
            burnoutScore: 3
        )
    }
}

struct LearningArticle: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var summary: String
    var articleMarkdown: String
    var category: LearningCategory
    var imageName: String
    var references: [LearningReference]

    static let sample = LearningArticle(
        id: UUID(),
        title: "Sunlight and Your Circadian Rhythm",
        summary: "Morning light is the anchor for hormonal balance and energy.",
        articleMarkdown: """
        Exposure to natural light anchors your circadian rhythm. Aim for 15 minutes of morning sunlight to boost energy and sleep quality.
        """,
        category: .favorites,
        imageName: "energizedBot",
        references: [
            LearningReference(
                title: "Morning light exposure for circadian entrainment",
                url: URL(string: "https://pubmed.ncbi.nlm.nih.gov/000000")!
            )
        ]
    )
}

struct LearningReference: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var url: URL

    init(id: UUID = UUID(), title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }
}

enum LearningCategory: String, Codable, CaseIterable, Hashable {
    case favorites
    case supplements
    case concepts

    var title: String {
        switch self {
        case .favorites:
            return "My Favorites"
        case .supplements:
            return "Supplements"
        case .concepts:
            return "Concepts"
        }
    }
}

struct JourneySnapshot: Identifiable, Codable {
    var id: UUID
    var dateRangeDescription: String
    var core4CompletionRate: Double
    var averageMood: Double
    var averageEnergy: Double
    var longestStreak: Int

    static let weekly = JourneySnapshot(
        id: UUID(),
        dateRangeDescription: "This Week",
        core4CompletionRate: 0.57,
        averageMood: 3.4,
        averageEnergy: 3.8,
        longestStreak: 3
    )
}

struct DailyJourneyScore: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var score: Double

    init(id: UUID = UUID(), date: Date, score: Double) {
        self.id = id
        self.date = date
        self.score = score
    }
}

struct AuthSession: Codable {
    var userID: UUID
    var email: String
    var accessToken: String
    var refreshToken: String
}
