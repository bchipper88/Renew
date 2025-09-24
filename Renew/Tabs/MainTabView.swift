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

            ToolsView()
                .tabItem { Label(MainTab.tools.title, systemImage: MainTab.tools.icon) }
                .tag(MainTab.tools)

            ProfileView()
                .tabItem { Label(MainTab.profile.title, systemImage: MainTab.profile.icon) }
                .tag(MainTab.profile)
        }
        .tint(.teal)
    }
}

enum MainTab: Hashable {
    case today, journal, learning, tools, profile

    var title: String {
        switch self {
        case .today: return "Today"
        case .journal: return "Journal"
        case .learning: return "Learn"
        case .tools: return "Boosts"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .today: return "circle.dotted"
        case .journal: return "square.and.pencil"
        case .learning: return "book"
        case .tools: return "wand.and.stars"
        case .profile: return "person.crop.circle"
        }
    }
}
