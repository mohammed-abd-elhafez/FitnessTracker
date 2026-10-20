# Code Review: FitnessTracker

## Summary

This archive contains a promising SwiftUI/SwiftData/HealthKit fitness tracker with sensible MVVM/Clean Architecture boundaries, protocol-based dependency injection, and good domain-level tests. However, it is not currently mergeable or release-ready: the checked-in repository cannot be built by its own CI, the source has likely/definite Swift 6 build blockers, and several failure paths can silently lose or misrepresent user data.

**Verdict: Request Changes**

## Review scope and verification

I reviewed all Swift source files, unit/UI tests, CI/Fastlane configuration, documentation, localization, privacy resources, persistence, HealthKit, notifications, and widget-sharing code.

I could not run `xcodebuild` or Swift tests in this Linux sandbox because Swift/Xcode are unavailable and the archive contains no `.xcodeproj`, `.xcworkspace`, or `Package.swift`. The project also documents that it has never been compiled (`README.md:38-40`), so all compile findings below should be verified on macOS with Xcode 16 / Swift 6 and complete strict-concurrency checking enabled.

## Critical issues — must fix before merge

### 1. The checked-in repository cannot build or run CI

**References:** `README.md:12-26`, `.github/workflows/ci.yml:29-37`, `fastlane/Fastfile:5-15`

The archive has no Xcode project or workspace. The README requires a developer to create one manually, add target membership, configure capabilities, add localizations, and create the widget target. In contrast, CI and Fastlane immediately invoke `FitnessTracker.xcodeproj`.

As checked in:

- CI cannot resolve `FitnessTracker.xcodeproj`.
- Unit and UI test targets are not represented.
- HealthKit/App Groups entitlements are not represented.
- The widget extension target is not represented.
- There is no reproducible build configuration for deployment target, Swift version, strict concurrency, signing, or resources.

**Recommendation:** Commit the generated `.xcodeproj` (or migrate to a complete Swift Package/project-generation approach), including app, unit-test, UI-test, and widget targets, source/resource membership, capabilities, entitlements, localization, and the exact build settings used by CI. Then run a real build and test job before treating the repository as reviewable/ship-ready. If this is intentionally a pre-Xcode scaffold, disable or gate CI/Fastlane until the project is committed rather than presenting a permanently failing pipeline.

### 2. Production source violates the declared Sendable boundary

**References:** `FitnessTracker/Domain/Repositories/HealthDataRepository.swift:3-9`, `FitnessTracker/Data/Repositories/MockRepositories.swift:3-10`, `CLAUDE.md:78-79`

`HealthDataRepository` refines `Sendable`, but `MockHealthRepository` is a value type conforming to that protocol while storing `var error: (any Error)?`. Under Swift 6 complete strict-concurrency checking, this is expected to produce a non-Sendable stored-property/conformance diagnostic. The mock lives under the application source tree, so it is not isolated to tests.

**Recommendation:** Make the injected failure type a known `Sendable` type such as `AppError?`, or create a dedicated `Sendable` test error. If an unchecked design is truly required, isolate and document the synchronization boundary rather than weakening the whole repository protocol.

`NotificationService` should also be checked in the real SDK: `NotificationScheduling` is `Sendable`, while `NotificationService` stores `UNUserNotificationCenter` (`FitnessTracker/Data/Notifications/NotificationService.swift:5-8`). If the SDK does not provide an unchecked Sendable conformance for that class, isolate the service behind an appropriate actor or a narrowly scoped wrapper.

### 3. SwiftUI progress picker uses a non-Hashable selection type

**References:** `FitnessTracker/Domain/Entities/ProgressPeriod.swift:4-5`, `FitnessTracker/Features/Progress/ProgressTabView.swift:44-46`

`Picker` selection values and `.tag(...)` values must be `Hashable`, but `ProgressPeriod` only conforms to `CaseIterable, Sendable`. This is a source-level compile blocker once the project is created.

**Recommendation:** Add `Hashable` (and, if useful for persistence or navigation, `Equatable`) to `ProgressPeriod`:

```swift
enum ProgressPeriod: CaseIterable, Hashable, Sendable {
    case week, month
}
```

### 4. SwiftData failure silently switches the app to volatile storage

**References:** `FitnessTracker/App/AppContainer.swift:14-25`

If the persistent container cannot be opened, the app logs the error and replaces both repositories with new in-memory mocks. The UI is not told that storage is unavailable. Existing workouts/goals disappear for the session, and any new writes made through the fallback disappear on relaunch. This can turn migration, corruption, or low-storage failures into apparent data loss.

**Recommendation:** Do not silently substitute production persistence with empty mocks. Surface a storage-recovery state to the UI, offer a controlled retry/recovery path, and prevent destructive writes until persistence is healthy. In-memory repositories should be used only for previews/tests or explicitly marked UI-test mode.

## Major issues — should fix before release

### 5. Reminder settings can claim a reminder is enabled when no notification exists

**References:** `FitnessTracker/Features/Settings/SettingsViewModel.swift:88-99`, `FitnessTracker/Data/Notifications/NotificationService.swift:25-34`

When changing the time of an enabled reminder, the view model persists the new hour/minute before scheduling succeeds. The concrete service removes the old pending notification before attempting to add the new one. If `add` fails, the old reminder is gone, preferences contain the new time, and the UI still considers the reminder enabled.

**Recommendation:** Make the operation transactional from the user's perspective: validate the new time, schedule the replacement successfully, then commit preferences. If replacement fails, restore the previous preferences and preserve or recreate the old request. Add a test covering failure while an existing reminder is active.

### 6. Widget sharing is not deployable as checked in

**References:** `FitnessTracker/Core/Utilities/AppGroup.swift:4-7`, `FitnessTracker/Data/Widgets/AppGroupSnapshotStore.swift:15-25`, `docs/RELEASE.md:7-23`

The App Group identifier is the placeholder `group.com.example.FitnessTracker`, and no app/widget entitlements or widget target are committed. When the shared suite is unavailable, snapshot publishing only logs and returns, so the main app can appear healthy while the widget never updates.

**Recommendation:** Commit the real App Group configuration and matching entitlements for both targets. Validate the suite during startup or widget setup and expose a diagnosable configuration error instead of silently treating publishing as successful. Add an app/widget integration or at least snapshot round-trip test.

### 7. Workout validation permits negative or non-finite calories

**References:** `FitnessTracker/Features/Workouts/WorkoutFormView.swift:44-49`, `FitnessTracker/Domain/UseCases/ValidateWorkout.swift:16-39`, `FitnessTracker/Data/Persistence/PersistenceMapping.swift:14-25`

The calories field is user-editable, but validation checks duration, future dates, notes length, and strength sets only. `caloriesBurned` is then persisted without a finite/non-negative constraint. Negative values can be entered and displayed as valid workout metrics; programmatic callers can also supply `NaN` or infinity.

**Recommendation:** Add a calories validation case and enforce `value.isFinite && value >= 0` before saving. Consider normalizing or rejecting invalid legacy values when mapping persisted data. Add boundary tests for negative, `NaN`, infinity, zero, and `nil`.

### 8. Workout deletion and reloads can race and restore stale rows

**References:** `FitnessTracker/Features/Workouts/WorkoutsView.swift:61-65`, `FitnessTracker/Features/Workouts/WorkoutsViewModel.swift:18-28`

Deletion is launched in an untracked `Task` from the view, while `load()` has no overlap/version guard. A refresh or load that completes after a deletion can replace the locally updated list with an older repository result, or concurrent loads can finish out of order.

**Recommendation:** Keep mutation orchestration in the view model, serialize load/delete operations, or use a load-generation token. After a successful delete, either update state only from the serialized operation or perform a fresh load before exposing the final list. Add a test for concurrent refresh/delete behavior.

## Minor issues and polish

### 9. Resolved error messages are passed back through `LocalizedStringKey`

**References:** `FitnessTracker/Features/Today/TodayView.swift:29-35`, `FitnessTracker/Features/Progress/ProgressTabView.swift:27-30`, `FitnessTracker/Features/Workouts/WorkoutsView.swift:41-45`

The view models store `error.localizedDescription`, which is already resolved text, but the views pass it to `EmptyStateView.message`, whose type is `LocalizedStringKey`. This treats dynamic text as a localization key and can produce inconsistent fallback/localization behavior.

**Recommendation:** Either keep typed `AppError` values and map them to catalog keys at the view boundary, or let the empty state render dynamic errors with `Text(verbatim:)`.

### 10. Imperial weight input still says “Weight (kg)”

**References:** `FitnessTracker/Features/Workouts/WorkoutSetsSection.swift:17-20`, `FitnessTracker/Resources/Localizable.xcstrings:741-755`

The form displays the selected `lb` suffix but uses a localization value whose label is hardcoded as `Weight (kg)`. This is misleading whenever imperial units are selected.

**Recommendation:** Use a unit-neutral localization key such as `Weight`, and render the selected unit separately, or provide unit-specific labels.

### 11. Widget sources are excluded from SwiftLint

**References:** `.swiftlint.yml:1-3`, `Widgets/FitnessWidget.swift`

The lint configuration includes `FitnessTracker` and `Tests`, but not `Widgets`. The widget is therefore outside the stated lint gate even though it is production code.

**Recommendation:** Include `Widgets` once the widget target is committed, or lint each target's source set explicitly.

## Test coverage assessment

### Covered well

- Goal progress boundaries and clamping.
- Streak gaps, date normalization, and zero-count behavior.
- Workout duration, future-date tolerance, notes length, and strength-set validation.
- SwiftData CRUD, ordering, and relationship replacement using in-memory stores.
- View-model loading/error states, goal seeding, reminder enable/disable flows, and unit conversions.
- Chart accessibility descriptor intent and localization resources are present.

### Missing or insufficient

- No verified build/test run because the project/targets are absent.
- No on-disk SwiftData reopen/migration test, despite the release requirement to relaunch and confirm persistence (`docs/RELEASE.md:37`).
- UI save test only verifies that the sheet closes; it does not verify the row, strength sets, or persistence after relaunch (`Tests/UITests/FitnessTrackerUITests.swift:33-42`).
- `retryAfterFailureRecovers` constructs a new view model rather than retrying the failed instance (`Tests/UnitTests/DashboardViewModelTests.swift:51-57`).
- No tests for notification replacement failure/rollback, malformed reminder preferences, App Group snapshot round-trip/unavailable suite, HealthKit error mapping, invalid calories, or concurrent load/delete behavior.
- No real-device verification for HealthKit authorization/no-data behavior, notification delivery, widget refresh, Arabic RTL, Dynamic Type, Dark Mode, or VoiceOver.

## Positive feedback

- The architecture has clear dependency injection and protocol boundaries (`FitnessTracker/App/AppContainer.swift:4-12`; `FitnessTracker/Domain/Repositories/`).
- Domain/use-case logic is kept out of views, and view models are Main Actor isolated.
- SwiftData repositories are actor-isolated and map persistence models to domain models cleanly.
- The code avoids force unwraps, `try!`, and `fatalError` in production source.
- The domain tests are stronger than average for an uncompiled scaffold, particularly around validation, streaks, goal progress, and SwiftData relationship replacement.
- Localization and accessibility were considered from the start, including an accessibility chart descriptor and Arabic resources.
- No hardcoded secrets, SQL injection paths, or network data exfiltration paths were found in the reviewed source.

## Questions for the author

1. Is the missing Xcode project intentional scaffolding, or is the archive expected to be directly buildable? If intentional, should CI/Fastlane remain disabled until Phase 0 is complete?
2. What user-facing behavior is desired when SwiftData cannot open: retry, recovery/export, read-only mode, or an explicit storage error?
3. Should changing an enabled reminder be atomic, preserving the previous schedule if the replacement cannot be installed?
4. Are manual workout calories allowed to be omitted only, or should zero/positive finite values be enforced?
5. Should non-strength workout types discard existing sets when the user changes type, or should the data be retained and surfaced?

## Recommended merge order

1. Commit the Xcode app/test/UI-test/widget targets and run the first macOS build with Swift 6 complete concurrency checking.
2. Fix the `ProgressPeriod: Hashable` compile blocker and all Sendable diagnostics, including the notification service if the SDK reports one.
3. Remove the silent in-memory production fallback and make persistence/configuration failures visible and safe.
4. Make notification replacement transactional and validate workout calories.
5. Add on-disk persistence, notification failure, widget snapshot, invalid-input, and concurrency tests.
6. Complete real-device checks for HealthKit, notifications, widget refresh, accessibility, RTL, Dynamic Type, and Dark Mode.
