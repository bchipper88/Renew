import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label(MainTab.today.title, systemImage: MainTab.today.icon) }
                .tag(MainTab.today)

            JournalView()
                .tabItem { Label(MainTab.journal.title, systemImage: MainTab.journal.icon) }
                .tag(MainTab.journal)

            LearningView()
                .tabItem { Label(MainTab.learning.title, systemImage: MainTab.learning.icon) }
                .tag(MainTab.learning)

            AnalyticsView()
                .tabItem { Label(MainTab.analytics.title, systemImage: MainTab.analytics.icon) }
                .tag(MainTab.analytics)

            SettingsView()
                .tabItem { Label(MainTab.settings.title, systemImage: MainTab.settings.icon) }
                .tag(MainTab.settings)
        }
        .tint(.teal)
    }
}

enum MainTab: Hashable {
    case today, journal, learning, analytics, settings

    var title: String {
        switch self {
        case .today: return "Today"
        case .journal: return "Journal"
        case .learning: return "Learning"
        case .analytics: return "Analytics"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .today: return "circle.dotted"
        case .journal: return "square.and.pencil"
        case .learning: return "book"
        case .analytics: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape"
        }
    }
}
