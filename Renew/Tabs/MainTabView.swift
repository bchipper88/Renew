import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            JournalView()
                .tabItem { Label(MainTab.journal.title, systemImage: MainTab.journal.icon) }
                .tag(MainTab.journal)

            LearningView()
                .tabItem { Label(MainTab.learning.title, systemImage: MainTab.learning.icon) }
                .tag(MainTab.learning)

            TodayView()
                .tabItem { Label(MainTab.today.title, systemImage: MainTab.today.icon) }
                .tag(MainTab.today)

            JourneyView()
                .tabItem { Label(MainTab.journey.title, systemImage: MainTab.journey.icon) }
                .tag(MainTab.journey)

            SettingsView()
                .tabItem { Label(MainTab.settings.title, systemImage: MainTab.settings.icon) }
                .tag(MainTab.settings)
        }
        .tint(.teal)
    }
}

enum MainTab: Hashable {
    case today, journal, learning, journey, settings

    var title: String {
        switch self {
        case .today: return "Today"
        case .journal: return "Journal"
        case .learning: return "Learning"
        case .journey: return "Journey"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .today: return "circle.dotted"
        case .journal: return "square.and.pencil"
        case .learning: return "book"
        case .journey: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape"
        }
    }
}
