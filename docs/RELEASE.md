# Capabilities, device testing and release

None of this can be done without Xcode. Do it in order. Nothing here was verified by a build.

## 1. Project capabilities and Info.plist (needed from Phase 3)

App target > Signing & Capabilities:
- **HealthKit** (no background delivery needed yet).
- **App Groups**: create `group.<your.bundle.id>` and put the same string in
  `FitnessTracker/Core/Utilities/AppGroup.swift` (`AppGroup.identifier`).

App target > Info (or build setting `INFOPLIST_KEY_...`):
- `NSHealthShareUsageDescription`: "FitnessTracker reads your steps, distance and active energy to show your daily progress. Your data stays on your device."
- `NSHealthUpdateUsageDescription`: required key even though the app does not write; reuse the sentence above.

Add `FitnessTracker/Resources/PrivacyInfo.xcprivacy` to the app target (declares UserDefaults use, no tracking, no collected data).

## 2. Widget extension (Phase 8 of the roadmap)

1. File > New > Target > **Widget Extension**, name `FitnessWidget`, untick Live Activity and configuration intent.
2. Delete the generated Swift files and add the sources listed at the top of `Widgets/FitnessWidget.swift`.
3. Give the widget target the same **App Groups** capability and group id.
4. Run on a device: log steps, open the app (this publishes the snapshot), add the widget.

## 3. UI tests

Add a **UI Testing Bundle** target and put `Tests/UITests/FitnessTrackerUITests.swift` in it. The app reads the launch argument `UI_TESTING` to use mock data and skip onboarding.

## 4. Real-device checklist (cannot be verified in the Simulator)

- [ ] Onboarding: Health permission sheet appears; allow all, then deny all. Today shows data / the "no data" hint and never crashes.
- [ ] Steps, distance and active energy match the Health app for today.
- [ ] Progress chart shows 7 and 30 days; goal line at the step target; VoiceOver reads the audio graph.
- [ ] Reminder: enable in Settings, accept permission, change time, confirm the notification fires at the right time; disable cancels it; deny permission shows the hint.
- [ ] Widget shows today's progress and updates after opening the app.
- [ ] Arabic: switch device language, check RTL layout, no truncated text, Dynamic Type at the largest size, Dark Mode.
- [ ] Add, edit and delete a workout including strength sets; relaunch and confirm it persisted.

## 5. Release checklist

- [ ] All unit and UI tests pass in CI.
- [ ] No warnings with Strict Concurrency set to Complete; run Instruments (Time Profiler, Leaks) on a device.
- [ ] Replace the placeholder bundle id, `AppGroup.identifier` and the Fastlane/CI scheme names.
- [ ] App icon, screenshots (iPhone sizes, English and Arabic), release notes.
- [ ] Publish a **privacy policy** URL (required for HealthKit apps). Core statements: health data is read on device, is not sent to any server, is not used for advertising or sold, and the user can revoke access in Settings > Health.
- [ ] App Privacy labels: "Data Not Collected" (nothing leaves the device).
- [ ] Health disclaimer in the App Store description: for general fitness tracking, not medical diagnosis.
- [ ] Bump version/build, archive, upload with `fastlane beta`, run a TestFlight beta for at least a week.
