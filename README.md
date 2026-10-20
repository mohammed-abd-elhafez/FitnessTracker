# FitnessTracker

Native iOS fitness tracker (SwiftUI, SwiftData, HealthKit). Offline-first, privacy-first, Arabic + English.
Spec and roadmap: [docs/FitnessTracker-Project-Guide.md](docs/FitnessTracker-Project-Guide.md). Working rules: [CLAUDE.md](CLAUDE.md).

## Requirements

- macOS with Xcode 16+ (Swift 6)
- iOS 17.0+ deployment target
- Optional: `brew install swiftlint swiftformat`

## One-time Xcode project setup (Phase 0)

The `.xcodeproj` is created in Xcode, not by hand. The source files already exist in this repo.

1. Xcode > File > New > Project > iOS > **App**.
   - Product Name: `FitnessTracker`
   - Interface: **SwiftUI**, Language: **Swift**
   - Storage: **None** (SwiftData arrives in Phase 2)
   - Testing System: **Swift Testing**; tick **Include Tests** (UI tests optional)
   - Save it inside this repo folder, so it sits next to `FitnessTracker/` and `Tests/`. If Xcode makes a nested `FitnessTracker/FitnessTracker/`, merge: keep Xcode's `.xcodeproj` and use the repo's source files.
2. Delete the template files Xcode generated (`FitnessTrackerApp.swift`, `ContentView.swift`, template tests, `Assets.xcassets` may stay).
3. Drag the repo's `FitnessTracker/` folder into the app target (create **folder references or groups**, target membership: FitnessTracker). Drag `Tests/UnitTests` into the unit test target.
4. Build Settings (app target): iOS Deployment Target `17.0`, Swift Language Version `6`, Strict Concurrency Checking `Complete`.
5. Add the HealthKit and App Groups capabilities, the Health usage-description keys and the privacy manifest: see [docs/RELEASE.md](docs/RELEASE.md).
6. In the project, add `en` and `ar` localizations (Project > Info > Localizations).

## Build and test

```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16' test
swiftlint
```

Adjust the simulator name to one you have installed (`xcrun simctl list devices`).

## Status

All roadmap code is written but **has never been compiled or run** (authored without Xcode). Expect a first round of compile fixes. Real-device checks (HealthKit, notifications, widget) are listed in [docs/RELEASE.md](docs/RELEASE.md).

- Phases 0-3: tab shell, SwiftData workouts/goals CRUD, HealthKit service, onboarding
- Phase 4+: Swift Charts progress with streaks, daily reminder, goal editing, widget sources (`Widgets/`), UI tests, CI (`.github/workflows`), Fastlane, localization (en/ar)

## Layout

See the project structure section in [CLAUDE.md](CLAUDE.md).
