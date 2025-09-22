# Renew App Architecture

## Overview
Renew is an iOS and iPadOS SwiftUI application that guides burned-out professionals toward recovery by reinforcing four daily habits ("Core 4") with journaling, analytics, and learning content. The app integrates with HealthKit, Screen Time, Supabase, StoreKit, and UserNotifications while maintaining a light, hopeful aesthetic.

## Core Principles
- **State-first design**: Observable view models backed by Combine publishers and Supabase live queries keep the UI reactive and resilient to offline states.
- **Modular features**: Each tab (Today, Journal, Learning, Analytics, Settings) owns its view hierarchy, view models, and data access layer built on shared services.
- **Task-oriented onboarding**: Authentication, permissions, and subscription trial happen in a guided flow that collects user goals and entitlements before unlocking the main tabs.
- **Privacy & security**: Supabase policies enforce per-user data access. Sensitive state (sessions, tokens) is stored securely in the keychain.

## Layers
1. **App Shell** (`RenewApp`)
   - Bootstraps dependency container (services, repositories, stores)
   - Routes between `AuthGate`, `OnboardingFlow`, and the main tab bar.
2. **Feature Modules** (`Features/`)
   - Views: SwiftUI screens and components per feature.
   - ViewModels: `ObservableObject` classes that combine domain use-cases with UI logic.
   - Navigation: Enum-based routing within feature modules.
3. **Domain** (`Domain/`)
   - Models: `CoreHabit`, `HabitLog`, `JournalEntry`, etc.
   - Use Cases: Coordinators that execute feature-specific logic (e.g., `CompleteHabitUseCase`).
4. **Data** (`Data/`)
   - Repositories abstract Supabase, HealthKit, and ScreenTime access.
   - Clients and SDK wrappers isolate third-party APIs from feature code.
5. **Shared UI** (`SharedUI/`)
   - Design system: colors, gradients, typography, glassmorphism components.
   - Controls: progress rings, streak badges, empty states.
6. **Support** (`Support/`)
   - Utilities: Date formatters, analytics helpers, haptic engine.
   - Services: NotificationScheduler, SubscriptionManager, AuthSessionManager.

## Data Flow
```
View ↔ ViewModel ↔ UseCase ↔ Repository ↔ Remote/Device APIs
```
- Views bind to view model `@Published` state. User intents call view model methods.
- View models delegate business actions to use cases (testable units containing rules).
- Use cases query repositories for data persistence or side effects.
- Repositories bridge to Supabase (via REST/RPC client), HealthKit, ScreenTime, StoreKit, and local cache.

## Key Services
- `AuthService`: wraps Supabase auth providers and handles keychain persistence.
- `UserProfileRepository`: CRUD for `user_profile` table scoped to the signed-in user.
- `HabitRepository`: Reads/writes `habit_log`, merges HealthKit and Screen Time data sources.
- `JournalRepository`: Manages journaling entries with optimistic updates.
- `LearningRepository`: Fetches markdown learning modules and caches them locally.
- `SubscriptionService`: Coordinates StoreKit configuration, trial activation, and entitlement checks.
- `NotificationScheduler`: Configures morning/midday/evening reminders and learning nudges.

## Dependency Graph
```
AppContainer
├── AuthService
├── SubscriptionService
├── PermissionCoordinator
├── NotificationScheduler
├── ProfileStore
├── HabitStore
├── JournalStore
├── LearningStore
└── AnalyticsService
```
- `AppContainer` created at launch and injected into environment.
- Stores expose `@Published` state for features via `ObservableObject` wrappers.

## Navigation Flow
1. `AuthGateView`
   - No session → `SignInView`
   - Session but incomplete profile → `OnboardingFlow`
   - Session with trial/active subscription → `MainTabView`
2. `OnboardingFlow`
   - Welcome → Goals → HealthKit Permissions → Notifications → Trial Start
3. `MainTabView`
   - Tab stack per feature with nested navigation (e.g., `TodayDetail`, `JournalEntryEditor`).

## State Persistence
- `AppState` (in-memory) tracks session, profile, subscription, core habit completion, streaks.
- Local caching via `FileManager` or `AppStorage` for offline survivability (e.g., last habit log snapshot).
- Cloud persistence via Supabase; HealthKit and ScreenTime data stay device-local per Apple policies.

## Testing Strategy
- Unit tests for view models, use cases, repositories using protocol-based dependency injection.
- UI snapshot/tests via Xcode previews + XCUITest for onboarding and core flows.
- Integration tests for StoreKit transactions using StoreKit Test configuration.

## Tooling
- SwiftLint for style enforcement.
- Tuist or XcodeGen (future) for reproducible project generation.
- Fastlane lane for TestFlight builds and metadata automation.

## Open Questions
- How to simulate Screen Time API for development.
- Offline strategies for Supabase writes.
- Monetization experiments beyond monthly plan.
