import SwiftUI
import OSLog

@main
struct RenewApp: App {
    @StateObject private var environment = AppEnvironment()

    init() {
        AppLogger.lifecycle.debug("RenewApp init")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment.state)
                .environmentObject(environment.container)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Group {
            if !state.isSignedIn {
                AuthGateView()
            } else if state.shouldShowOnboarding {
                OnboardingFlowView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            AppLogger.lifecycle.debug("RootView appeared - isSignedIn: \(state.isSignedIn), onboarding: \(state.shouldShowOnboarding)")
        }
        .onChange(of: state.isSignedIn) { oldValue, newValue in
            AppLogger.lifecycle.debug("RootView state.isSignedIn changed: \(oldValue) -> \(newValue)")
        }
        .onChange(of: state.shouldShowOnboarding) { oldValue, newValue in
            AppLogger.lifecycle.debug("RootView shouldShowOnboarding changed: \(oldValue) -> \(newValue)")
        }
        .animation(.easeInOut, value: state.isSignedIn)
        .animation(.easeInOut, value: state.shouldShowOnboarding)
    }
}
