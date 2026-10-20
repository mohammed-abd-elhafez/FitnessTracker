# CLAUDE.md: FitnessTracker (iOS)

This file is the persistent context for this repository. Read it fully before making changes. The full product spec and learning roadmap live in `docs/FitnessTracker-Project-Guide.md`; treat that document as the source of truth for scope and architecture.

## Project

Native iOS Fitness Tracker. Reads activity data from HealthKit, lets users log workouts, set daily goals, view progress charts, and get reminders. Offline-first, privacy-first. Bilingual (Arabic RTL + English).

## Tech Stack

- Swift 6, SwiftUI, iOS 17+ deployment target
- State: Observation framework (`@Observable`), no Combine unless truly needed
- Concurrency: async/await, actors, `@MainActor` for UI state
- Persistence: SwiftData
- Health data: HealthKit (read-only in MVP)
- Charts: Swift Charts
- Notifications: UserNotifications
- Widgets (later phase): WidgetKit + App Intents
- Tests: Swift Testing (unit) + XCUITest (UI)
- Dependencies: Swift Package Manager only. **No third-party packages in the MVP** unless I approve one explicitly.

## Architecture

MVVM + simplified Clean Architecture, three layers:

- `Domain/`: entities, repository protocols, use cases. Pure Swift, no framework imports except Foundation.
- `Data/`: SwiftData stores, `HealthKitService`, `NotificationService`, repository implementations.
- `Features/<Name>/`: SwiftUI views and their `@Observable` ViewModels.

Rules:
- ViewModels depend on **protocols**, never on concrete services.
- Dependencies are injected through `init` (composition root in `App/AppContainer.swift`). No hidden singletons.
- Business logic (calculations, streaks, date math) lives in Domain/use cases, never inside Views.
- Data flows one way: View action -> ViewModel -> state -> View.

## Project Structure

```
FitnessTracker/
  App/            entry point, AppContainer (DI)
  Core/           DesignSystem, Extensions, Utilities, Errors
  Domain/         Entities, Repositories (protocols), UseCases
  Data/           Persistence, HealthKit, Notifications, Repositories
  Features/       Onboarding, Today, Workouts, Progress, Settings
  Resources/      Localizable.xcstrings, Assets.xcassets
Tests/            UnitTests, UITests
docs/             project guide and decisions
```

## Commands

Adjust the scheme and simulator names to match the actual project after creation.

```bash
# Build
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16' build

# Unit tests
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16' test

# Lint / format (if configured)
swiftlint
swiftformat .
```

Always run build and tests before declaring a task done.

## Coding Standards

- Follow the Swift API Design Guidelines.
- Prefer `struct` and `let`; use `final class` only when reference semantics are needed.
- `private` by default; widen access only when required.
- **Never** use force unwrap (`!`), `try!`, or `fatalError` in production code. Handle errors with the `AppError` enum.
- No `print`; use `os.Logger` with a subsystem and category.
- Keep Views small (about 100 lines max). Extract subviews.
- Use semantic fonts (`Font.TextStyle`) only, to support Dynamic Type.
- All user-facing strings go in `Localizable.xcstrings`. No hardcoded strings in Views.
- Add `///` documentation to non-trivial public types and functions.
- Strict Concurrency Checking stays ON. Fix warnings; don't suppress them.

## Testing Requirements

- Every use case and ViewModel gets unit tests (Swift Testing).
- Repositories are tested against in-memory SwiftData.
- Provide a Mock for every service protocol.
- Target at least 70% coverage on Domain and ViewModels.
- Write tests alongside the feature, not afterwards.

## HealthKit Notes

- Requires the HealthKit capability and the `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription` Info.plist keys.
- HealthKit reports "authorized" even when read access is denied, so the UI must handle the "no data" state gracefully.
- HealthKit is the source of truth for health metrics; do not duplicate it in SwiftData except as a cache.
- The Simulator has limited HealthKit data; flag anything that needs a real device to verify.

## Accessibility and Localization

- Every interactive element has an accessibility label; charts have descriptors.
- Support Dark Mode, Dynamic Type, and VoiceOver.
- Arabic (RTL) and English must both work; avoid hardcoded left/right, use leading/trailing.

## Workflow Rules

- Work in small, reviewable steps. One feature or phase at a time.
- **Plan before coding** for anything touching more than two files: show the plan and wait for my approval.
- Make atomic commits using Conventional Commits (`feat(today): add progress ring`).
- Do not add dependencies, change the deployment target, or modify project capabilities without asking.
- If requirements are ambiguous or a decision has architectural impact, ask instead of guessing.
- Never mark something done if the build or tests fail. Report failures honestly.
- At the end of each task, summarize what changed, how it was verified, and what is next.

## Out of Scope (MVP)

Apple Watch app, CloudKit sync, Live Activities, social features, any backend or server. Do not build these unless asked.
