# Renew

Renew is an iOS & iPadOS SwiftUI app that helps burned-out professionals reclaim energy through the "Core 4" habits: screen time, sunlight, steps, and sleep. The app layers journaling, learning modules, analytics, and a 3-day premium trial on top of a calm, glassmorphic design system.

## Highlights
- **SwiftUI-first architecture** with feature modules (`Today`, `Journal`, `Learning`, `Journey`, `Settings`).
- **Onboarding flow** for goals, HealthKit permissions, notification opt-in, and StoreKit trial activation.
- **Service layer** wrapping Supabase, HealthKit, Screen Time, StoreKit, and notifications (stubbed for now).
- **Combine-powered stores** to keep UI reactive and testable.
- **Gradients and glass surfaces** that match the airy Renew brand direction.

## Project Structure
```
Renew/
├─ App/                # App entry, container, environment, shared state
├─ Auth/               # Auth gate screen + view model
├─ Onboarding/         # Multi-step onboarding implementation
├─ Tabs/               # Main tab container
├─ Features/           # Today, Journal, Learning, Journey, Settings modules
├─ Services/           # Auth, Habit, Journal, Learning, Subscription, Notification, Journey services
├─ Models/             # Shared data models and value types
├─ Support/            # Styling helpers, Info.plist
└─ Resources/          # Asset catalog (AppIcon placeholder)
```

Additional documentation lives in `Docs/ARCHITECTURE.md`.

## Requirements
- Xcode 15.4+ (Swift 5.9+)
- iOS 17 SDK or newer
- Swift Package Manager (bundled with Xcode)

## Getting Started
1. Open `Renew.xcodeproj` in Xcode.
2. Select the `Renew` scheme.
3. Choose an iPhone or iPad simulator running iOS 17+.
4. Build & run (⌘R).

Alternatively, build from the command line:
```bash
xcodebuild -scheme Renew -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' build
```

## Current Limitations
- Service implementations are mocked. Supabase, HealthKit, StoreKit, and Screen Time integrations return sample data.
- Notification scheduling requests authorization but does not handle denied states yet.
- Journey and streak logic use placeholder values.
- No automated test targets yet (unit & UI).

## Recommended Next Steps
1. **Supabase integration**
   - Replace stubbed services with real Supabase client calls.
   - Configure row-level security policies and Supabase functions for habit aggregation.
2. **HealthKit & Screen Time APIs**
   - Implement real data ingestion, background refresh, and error states.
   - Provide development fallbacks when permissions are unavailable.
3. **StoreKit 2 subscriptions**
   - Wire up 3-day trial, entitlement checks, and paywall experiences.
   - Add StoreKit configuration for local testing.
4. **Offline & caching strategy**
   - Add persistence for daily habit logs and journal entries using `FileManager` or Core Data.
5. **Testing**
   - Create unit tests for view models and services using protocol-based mocks.
   - Add snapshot/UI tests for onboarding and Today dashboard flows.
6. **Design polish**
   - Implement custom Core 4 progress rings, streak animations, and haptic feedback.
   - Replace placeholder copy and add localized strings.

## Manual QA Checklist
- Launch app → see Auth gate with sign-in options.
- Trigger mocked Sign in with Apple to unlock onboarding.
- Progress through onboarding steps and ensure trial completes.
- Verify Today tab shows four habit cards and streak tile.
- Create a new journal entry; ensure list updates.
- Navigate to Learning articles and open detail screens.
- Confirm Settings tab shows account info and static pages.

## License
Copyright © 2025 Renew. All rights reserved.
