# 🏋️ Fitness Tracker (iOS) — Project Guide & Learning Program

> وثيقة مشروع كاملة: Product Spec + Architecture + خطة تعليمية (Learning Program) بتبني تطبيق Fitness Tracker احترافي من الصفر باستخدام Swift و SwiftUI.

| البند | التفاصيل |
|---|---|
| **المنصة** | iOS 17+ (مع Widgets وApple Watch companion اختياري) |
| **اللغة** | Swift 6 |
| **الواجهات** | SwiftUI |
| **المدة المتوقعة** | 10–12 أسبوع (10–15 ساعة أسبوعيًا) |
| **المستوى** | متوسط → متقدم |
| **الهدف** | تطبيق جاهز للنشر على TestFlight/App Store + Portfolio قوي |

---

## 📑 جدول المحتويات
1. [نظرة عامة على المنتج](#1-نظرة-عامة-على-المنتج)
2. [المتطلبات (Requirements)](#2-المتطلبات-requirements)
3. [Tech Stack](#3-tech-stack)
4. [Architecture](#4-architecture)
5. [هيكل المشروع (Project Structure)](#5-هيكل-المشروع-project-structure)
6. [Data Model](#6-data-model)
7. [HealthKit Integration](#7-healthkit-integration)
8. [UI/UX والشاشات](#8-uiux-والشاشات)
9. [البرنامج التعليمي (Learning Roadmap)](#9-البرنامج-التعليمي-learning-roadmap)
10. [Testing Strategy](#10-testing-strategy)
11. [CI/CD والنشر](#11-cicd-والنشر)
12. [Coding Standards](#12-coding-standards)
13. [Privacy و Security](#13-privacy-و-security)
14. [Roadmap مستقبلي](#14-roadmap-مستقبلي)
15. [مصادر للتعلم](#15-مصادر-للتعلم)

---

## 1. نظرة عامة على المنتج

### الرؤية
تطبيق بيخلّي المستخدم يتابع نشاطه البدني (خطوات، تمارين، نوم، وزن) وأهدافه اليومية في مكان واحد، بواجهة بسيطة وبيانات مقروءة من **HealthKit**، مع تحفيز مستمر عن طريق الـ streaks والـ widgets.

### الشخصيات المستهدفة (Personas)
- **المبتدئ**: عايز يمشي أكتر ويتابع خطواته.
- **المتمرن المنتظم**: بيسجل تمارين الجيم (sets/reps/weight) ويتابع التقدم.
- **المهتم بالصحة**: بيتابع النوم والوزن والسعرات.

### Value Proposition
- كل بياناتك في مكان واحد وخاصة بيك (Privacy-first).
- أهداف يومية قابلة للتخصيص مع تذكيرات ذكية.
- رسوم بيانية توضح التقدم الأسبوعي والشهري.

---

## 2. المتطلبات (Requirements)

### 2.1 Functional Requirements

#### MVP (الإصدار الأول)
| ID | الميزة | الأولوية |
|---|---|---|
| F-01 | قراءة الخطوات والمسافة والسعرات من HealthKit | P0 |
| F-02 | Dashboard يومي (خطوات، سعرات، نشاط) | P0 |
| F-03 | تسجيل تمرين يدوي (نوع، مدة، شدة) | P0 |
| F-04 | تحديد أهداف يومية (خطوات/سعرات/دقائق) | P0 |
| F-05 | سجل التمارين (History) مع حذف وتعديل | P0 |
| F-06 | رسوم بيانية أسبوعية/شهرية (Swift Charts) | P1 |
| F-07 | إشعارات محلية لتذكير التمرين | P1 |
| F-08 | Onboarding وطلب أذونات HealthKit | P0 |

#### الإصدار الثاني (V2)
| ID | الميزة | الأولوية |
|---|---|---|
| F-09 | Home Screen Widgets (Small/Medium) | P1 |
| F-10 | Live Activities أثناء التمرين | P2 |
| F-11 | تتبع الوزن والنوم | P1 |
| F-12 | Streaks وإنجازات (Achievements) | P2 |
| F-13 | مزامنة iCloud بين الأجهزة (CloudKit) | P2 |
| F-14 | Apple Watch companion | P3 |
| F-15 | تصدير البيانات (CSV) | P3 |

### 2.2 Non-Functional Requirements
- **الأداء**: فتح التطبيق < 1 ثانية، سكرول 60fps.
- **الـ Offline**: التطبيق يشتغل بالكامل بدون إنترنت.
- **الـ Accessibility**: دعم Dynamic Type وVoiceOver وDark Mode.
- **الـ Localization**: عربي + إنجليزي (RTL كامل).
- **الخصوصية**: لا بيانات صحية تخرج من الجهاز بدون موافقة صريحة.
- **الجودة**: Test coverage للـ business logic ≥ 70%.

---

## 3. Tech Stack

| الطبقة | التقنية | السبب |
|---|---|---|
| UI | **SwiftUI** | حديث وأسرع في التطوير |
| State | **Observation framework (`@Observable`)** | بديل أبسط من Combine للـ state |
| Concurrency | **Swift Concurrency (async/await, Actors)** | آمن وواضح |
| Persistence | **SwiftData** | تخزين محلي متكامل مع SwiftUI |
| Health Data | **HealthKit** | المصدر الرسمي لبيانات الصحة |
| Charts | **Swift Charts** | رسوم بيانية native |
| Notifications | **UserNotifications** | تذكيرات محلية |
| Widgets | **WidgetKit + App Intents** | Widgets تفاعلية |
| Sync (V2) | **CloudKit** | مزامنة مجانية عبر iCloud |
| Testing | **Swift Testing + XCTest/XCUITest** | Unit وUI tests |
| Dependency Mgmt | **Swift Package Manager** | الرسمي |
| Linting | **SwiftLint + SwiftFormat** | توحيد الكود |
| CI/CD | **Xcode Cloud أو GitHub Actions + Fastlane** | أتمتة البناء والنشر |

> **قرار معماري:** مفيش مكتبات خارجية في الـ MVP عشان نتعلم الـ frameworks الأصلية الأول.

---

## 4. Architecture

### 4.1 النمط المعماري
بنستخدم **MVVM + Clean Architecture (مبسطة)** مع فصل واضح للطبقات:

```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│        SwiftUI Views  ↔  ViewModels         │
└───────────────────────┬─────────────────────┘
                        │ (Protocols)
┌───────────────────────▼─────────────────────┐
│                Domain Layer                 │
│     Entities · UseCases · Repository        │
│              Protocols (pure Swift)         │
└───────────────────────┬─────────────────────┘
                        │ (Implements)
┌───────────────────────▼─────────────────────┐
│                 Data Layer                  │
│  SwiftData Store · HealthKit Service ·      │
│  Notification Service · (CloudKit في V2)    │
└─────────────────────────────────────────────┘
```

### 4.2 مبادئ التصميم
- **Dependency Inversion**: الـ ViewModels بتعتمد على Protocols مش على implementations.
- **Single Responsibility**: كل Class له مسؤولية واحدة.
- **Unidirectional Data Flow**: View → Action → ViewModel → State → View.
- **Testability First**: كل service ليه protocol عشان نعمل Mock بسهولة.
- **Dependency Injection**: عن طريق `init` أو `Environment`، بدون Singletons مخفية.

### 4.3 مثال على الـ Protocol والـ ViewModel

```swift
// Domain
protocol HealthDataRepository {
    func requestAuthorization() async throws
    func steps(for date: Date) async throws -> Int
    func activeEnergy(for date: Date) async throws -> Double
}

// Presentation
@MainActor
@Observable
final class DashboardViewModel {
    private(set) var steps = 0
    private(set) var calories = 0.0
    private(set) var state: LoadState = .idle

    private let repository: HealthDataRepository

    init(repository: HealthDataRepository) {
        self.repository = repository
    }

    func load(for date: Date = .now) async {
        state = .loading
        do {
            async let s = repository.steps(for: date)
            async let c = repository.activeEnergy(for: date)
            (steps, calories) = try await (s, c)
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

enum LoadState: Equatable {
    case idle, loading, loaded
    case failed(String)
}
```

### 4.4 Navigation
- `NavigationStack` مع `NavigationPath` وـ`Router` بسيط لكل tab.
- `TabView` بـ 4 تابات: **Today · Workouts · Progress · Settings**.

### 4.5 Error Handling
- `AppError` enum موحد (`healthAccessDenied`, `storageFailure`, `networkUnavailable`, ...).
- رسائل واضحة للمستخدم مع Retry action، ومفيش `try!` أو `fatalError` في production code.

---

## 5. هيكل المشروع (Project Structure)

```
FitnessTracker/
├── App/
│   ├── FitnessTrackerApp.swift
│   └── AppContainer.swift          # Dependency Injection
├── Core/
│   ├── Extensions/
│   ├── Utilities/
│   ├── DesignSystem/               # Colors, Typography, Components
│   └── Errors/AppError.swift
├── Domain/
│   ├── Entities/                   # Workout, Goal, DailySummary
│   ├── Repositories/               # Protocols
│   └── UseCases/
├── Data/
│   ├── Persistence/                # SwiftData models & stores
│   ├── HealthKit/HealthKitService.swift
│   ├── Notifications/NotificationService.swift
│   └── Repositories/               # Implementations
├── Features/
│   ├── Onboarding/
│   ├── Today/                      # View + ViewModel
│   ├── Workouts/
│   ├── Progress/
│   └── Settings/
├── Widgets/                        # Widget extension target
├── Resources/
│   ├── Localizable.xcstrings
│   └── Assets.xcassets
└── Tests/
    ├── UnitTests/
    └── UITests/
```

---

## 6. Data Model

### 6.1 الكيانات الأساسية (SwiftData)

```swift
import SwiftData

@Model
final class Workout {
    @Attribute(.unique) var id: UUID
    var type: WorkoutType
    var startDate: Date
    var durationMinutes: Int
    var caloriesBurned: Double?
    var notes: String?
    @Relationship(deleteRule: .cascade) var exercises: [ExerciseSet] = []

    init(type: WorkoutType, startDate: Date, durationMinutes: Int) {
        self.id = UUID()
        self.type = type
        self.startDate = startDate
        self.durationMinutes = durationMinutes
    }
}

@Model
final class ExerciseSet {
    var name: String
    var reps: Int
    var weightKg: Double
    var workout: Workout?

    init(name: String, reps: Int, weightKg: Double) {
        self.name = name
        self.reps = reps
        self.weightKg = weightKg
    }
}

@Model
final class Goal {
    var kind: GoalKind          // steps, calories, activeMinutes
    var target: Double
    var createdAt: Date

    init(kind: GoalKind, target: Double) {
        self.kind = kind
        self.target = target
        self.createdAt = .now
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case running, walking, cycling, strength, yoga, swimming, hiit, other
}

enum GoalKind: String, Codable { case steps, calories, activeMinutes }
```

### 6.2 مصدر البيانات
| البيانات | المصدر |
|---|---|
| الخطوات، السعرات، النوم، الوزن | **HealthKit** (Read-only في MVP) |
| تمارين يدوية، Sets، الأهداف، الإعدادات | **SwiftData** |

> **قاعدة:** HealthKit هو الـ source of truth للبيانات الصحية، ومبنكررهاش في الـ database إلا للـ caching.

---

## 7. HealthKit Integration

### الإعداد
1. فعّل **HealthKit capability** في Xcode.
2. أضف في `Info.plist`:
   - `NSHealthShareUsageDescription`
   - `NSHealthUpdateUsageDescription`

### الأنواع المطلوبة
| Type | الاستخدام |
|---|---|
| `stepCount` | الخطوات |
| `distanceWalkingRunning` | المسافة |
| `activeEnergyBurned` | السعرات النشطة |
| `HKWorkoutType` | التمارين |
| `sleepAnalysis` (V2) | النوم |
| `bodyMass` (V2) | الوزن |

### مثال مبسط: قراءة الخطوات

```swift
import HealthKit

final class HealthKitService: HealthDataRepository {
    private let store = HKHealthStore()

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw AppError.healthUnavailable
        }
        let types: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned)
        ]
        try await store.requestAuthorization(toShare: [], read: types)
    }

    func steps(for date: Date) async throws -> Int {
        let type = HKQuantityType(.stepCount)
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: type, predicate: predicate),
            options: .cumulativeSum
        )
        let result = try await descriptor.result(for: store)
        return Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
    }

    func activeEnergy(for date: Date) async throws -> Double { /* مشابه */ 0 }
}
```

### ملاحظات مهمة
- HealthKit بيرجّع "authorized" حتى لو المستخدم رفض القراءة (لأسباب خصوصية)، فالـ UI لازم يتعامل مع "no data".
- اختبر على **جهاز حقيقي**؛ الـ Simulator محدود.
- استخدم `HKObserverQuery` + Background Delivery لتحديث الـ Widgets.

---

## 8. UI/UX والشاشات

### الشاشات
| الشاشة | المحتوى |
|---|---|
| **Onboarding** | شرح الفكرة، طلب أذونات HealthKit والإشعارات، اختيار الأهداف |
| **Today** | حلقات تقدم (Progress Rings) للأهداف، ملخص اليوم، آخر تمرين |
| **Workouts** | قائمة التمارين، زر إضافة، تفاصيل تمرين، تعديل/حذف |
| **Add Workout** | اختيار النوع، المدة، الـ Sets (لتمارين القوة)، ملاحظات |
| **Progress** | Swift Charts (أسبوعي/شهري)، مقارنة بالأهداف |
| **Settings** | الأهداف، الوحدات (kg/lb, km/mi)، الإشعارات، اللغة، الخصوصية |

### Design System
- **ألوان**: Primary + Secondary + Semantic (success/warning/error)، تدعم Dark Mode.
- **Typography**: `Font.TextStyle` فقط (Dynamic Type).
- **Spacing**: شبكة 4pt/8pt.
- **Components قابلة لإعادة الاستخدام**: `ProgressRing`, `StatCard`, `PrimaryButton`, `EmptyStateView`.
- **Haptics** عند إنجاز الهدف.

### Accessibility Checklist
- [ ] كل العناصر التفاعلية ليها `accessibilityLabel`.
- [ ] الرسوم البيانية ليها `accessibilityChartDescriptor`.
- [ ] تباين ألوان كافي (WCAG AA).
- [ ] اختبار بـ VoiceOver وأكبر حجم خط.
- [ ] دعم RTL كامل للعربي.

---

## 9. البرنامج التعليمي (Learning Roadmap)

> كل أسبوع فيه: **أهداف التعلم → المهام → Deliverable → Definition of Done**.
> اشتغل بـ Git من اليوم الأول، وكل أسبوع يبقى ليه branch و PR (حتى لو لوحدك).

### 🟢 المرحلة 1: الأساسيات (الأسبوع 1–2)

#### الأسبوع 1: Swift + SwiftUI Basics
- **أهداف التعلم**: Optionals، Structs vs Classes، Protocols، Closures، `@State`، `@Binding`، Lists، Navigation.
- **المهام**:
  - إنشاء المشروع وإعداد Git و SwiftLint.
  - بناء TabView بـ 4 شاشات (فاضية).
  - بناء قائمة Workouts بـ mock data.
- **Deliverable**: تطبيق بتنقل شغال وقائمة بيانات ثابتة.
- **DoD**: بيشتغل بدون warnings، ومرفوع على GitHub.

#### الأسبوع 2: Architecture + State Management
- **أهداف التعلم**: MVVM، `@Observable`، Dependency Injection، Protocols للـ Repositories.
- **المهام**:
  - تطبيق هيكل الـ Layers (Domain/Data/Presentation).
  - عمل `MockHealthRepository` و `DashboardViewModel`.
  - بناء `ProgressRing` component.
- **Deliverable**: شاشة Today شغالة ببيانات Mock عن طريق ViewModel.
- **DoD**: أول Unit test للـ ViewModel بيعدي.

### 🟡 المرحلة 2: البيانات (الأسبوع 3–5)

#### الأسبوع 3: SwiftData
- **أهداف التعلم**: `@Model`، `ModelContainer`، `@Query`، Relationships، Migrations.
- **المهام**: تخزين التمارين والأهداف، CRUD كامل، Add/Edit Workout.
- **Deliverable**: تسجيل تمرين وحفظه وعرضه بعد إعادة تشغيل التطبيق.
- **DoD**: Repository tests بـ in-memory store.

#### الأسبوع 4: HealthKit
- **أهداف التعلم**: Authorization، Statistics Queries، Observer Queries، التعامل مع الأذونات المرفوضة.
- **المهام**: `HealthKitService` حقيقي، Onboarding للأذونات، عرض الخطوات والسعرات على Today.
- **Deliverable**: بيانات حقيقية من جهازك على الـ Dashboard.
- **DoD**: التطبيق بيتعامل بشكل سليم مع حالة "رفض الإذن" و"لا توجد بيانات".

#### الأسبوع 5: Swift Concurrency + Error Handling
- **أهداف التعلم**: `async/await`، `async let`، `TaskGroup`، Actors، `@MainActor`، Cancellation.
- **المهام**: تحميل متوازي للبيانات، Loading/Error/Empty states، Pull-to-refresh، Retry.
- **Deliverable**: شاشات متينة مع حالات تحميل وخطأ واضحة.
- **DoD**: مفيش data races (فعّل Strict Concurrency Checking).

### 🟠 المرحلة 3: التجربة والميزات (الأسبوع 6–8)

#### الأسبوع 6: Swift Charts + Progress
- **المهام**: رسوم أسبوعية/شهرية، مقارنة بالهدف، Segmented picker للفترة.
- **Deliverable**: شاشة Progress كاملة.
- **DoD**: الرسوم متاحة لـ VoiceOver.

#### الأسبوع 7: Notifications + Goals + Streaks
- **المهام**: جدولة إشعارات محلية، منطق الـ Streak، شاشة الأهداف، Haptics.
- **Deliverable**: تذكيرات يومية وـ streak counter.
- **DoD**: الإشعارات بتتلغي وتتعدل بشكل صحيح عند تغيير الإعدادات.

#### الأسبوع 8: WidgetKit
- **أهداف التعلم**: Timeline Provider، App Groups، مشاركة البيانات مع الـ Extension، App Intents.
- **المهام**: Small + Medium Widget بحلقة التقدم.
- **Deliverable**: Widget بيعرض تقدم اليوم.
- **DoD**: الـ Widget بيتحدث بعد تغيّر البيانات.

### 🔴 المرحلة 4: الاحتراف (الأسبوع 9–12)

#### الأسبوع 9: Testing + Quality
- **المهام**: Unit tests للـ UseCases والـ ViewModels، UI tests للـ flows الأساسية، Snapshot tests (اختياري)، رفع الـ coverage ≥ 70%.
- **DoD**: Test suite بتعدي على CI.

#### الأسبوع 10: Localization + Accessibility + Polish
- **المهام**: `Localizable.xcstrings` (عربي/إنجليزي)، RTL، Dynamic Type، Dark Mode، Empty states، Animations.
- **DoD**: اختبار كامل بالعربي والإنجليزي.

#### الأسبوع 11: CI/CD + Performance
- **المهام**: GitHub Actions أو Xcode Cloud، Fastlane، Profiling بـ Instruments (Time Profiler, Leaks)، تحسين وقت الإقلاع.
- **DoD**: كل push بيعمل build + test تلقائي.

#### الأسبوع 12: النشر
- **المهام**: App Icon وScreenshots، Privacy Policy، App Privacy Labels، TestFlight Beta، تجميع feedback، تقديم للمراجعة.
- **Deliverable**: 🚀 التطبيق على TestFlight/App Store.

### 🔵 مشاريع إضافية (Stretch Goals)
- CloudKit sync بين iPhone وiPad.
- Live Activities أثناء التمرين.
- Apple Watch companion.
- تكامل مع Claude API لإنتاج ملخص أسبوعي ونصائح مخصصة.

---

## 10. Testing Strategy

| النوع | الأداة | الهدف |
|---|---|---|
| **Unit** | Swift Testing / XCTest | UseCases، ViewModels، Calculations |
| **Integration** | XCTest + in-memory SwiftData | Repositories |
| **UI** | XCUITest | Onboarding، إضافة تمرين، تعديل هدف |
| **Accessibility** | Accessibility Inspector | VoiceOver وDynamic Type |
| **Manual** | جهاز حقيقي | HealthKit والإشعارات والـ Widgets |

### مثال Unit Test

```swift
import Testing
@testable import FitnessTracker

@MainActor
struct DashboardViewModelTests {
    @Test func loadSetsStepsOnSuccess() async {
        let repo = MockHealthRepository(steps: 8_500, calories: 420)
        let vm = DashboardViewModel(repository: repo)

        await vm.load()

        #expect(vm.steps == 8_500)
        #expect(vm.state == .loaded)
    }

    @Test func loadSetsFailedOnError() async {
        let repo = MockHealthRepository(error: AppError.healthUnavailable)
        let vm = DashboardViewModel(repository: repo)

        await vm.load()

        if case .failed = vm.state { } else { Issue.record("Expected failed state") }
    }
}
```

> **قاعدة:** أي منطق (حسابات، streaks، تواريخ) لازم يتغطى بـ tests قبل ما نعتمد عليه في الـ UI.

---

## 11. CI/CD والنشر

### Pipeline مقترح
```
Push/PR → SwiftLint → Build → Unit Tests → UI Tests
                                  │
              main branch ────────▼
                      Archive → TestFlight (Fastlane)
```

### Git Workflow
- **Branches**: `main` (مستقر) · `develop` · `feature/*` · `fix/*`.
- **Commits**: [Conventional Commits](https://www.conventionalcommits.org) مثل `feat(today): add progress ring`.
- **PRs**: صغيرة، ولازم يعدّوا الـ CI قبل الدمج.

### Release Checklist
- [ ] كل الـ tests بتعدي.
- [ ] اختبار على جهاز حقيقي وأكتر من حجم شاشة.
- [ ] مراجعة الـ Privacy Manifest وـ App Privacy Labels.
- [ ] تحديث Version/Build number.
- [ ] Screenshots وRelease Notes.
- [ ] Beta على TestFlight لمدة أسبوع على الأقل.

---

## 12. Coding Standards

- اتبع [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- فضّل `struct` و`let`، واستخدم `final class` لما تحتاج reference type.
- Access control صريح (`private` افتراضيًا).
- ممنوع: `force unwrap (!)` و`try!` و`print` في production، استخدم `Logger` من `os`.
- كل View أقل من ~100 سطر؛ قسّمها لـ subviews.
- الـ Logic ما يبقاش جوه الـ View.
- كل Public API ليه توثيق `///`.
- فعّل **Strict Concurrency Checking** وعالج التحذيرات.

### Logging
```swift
import os
extension Logger {
    static let health = Logger(subsystem: "com.yourname.FitnessTracker", category: "health")
}
```

---

## 13. Privacy و Security

- طلب أقل الأذونات الممكنة، مع شرح واضح لسبب كل إذن.
- بيانات الصحة **ما بتتبعتش لأي سيرفر** بدون موافقة صريحة.
- لو استخدمت CloudKit، البيانات في الـ **Private Database** للمستخدم.
- أي مفاتيح/Secrets (لو ضفت APIs) ما تتخزنش في الكود؛ استخدم Keychain وإعدادات الـ build.
- جهّز **Privacy Policy** واضحة قبل النشر (مطلوبة لتطبيقات HealthKit).
- App Store Review: ممنوع استخدام بيانات HealthKit للإعلانات أو بيعها.

> ⚠️ التطبيق ده لأغراض المتابعة واللياقة العامة، وليس أداة تشخيص طبي.

---

## 14. Roadmap مستقبلي

| الإصدار | المحتوى |
|---|---|
| **v1.0** | Dashboard، تمارين، أهداف، Charts، إشعارات |
| **v1.1** | Widgets، Streaks، Dark Mode كامل |
| **v1.2** | النوم والوزن، تصدير CSV |
| **v2.0** | CloudKit Sync، Live Activities |
| **v2.1** | Apple Watch App |
| **v3.0** | AI Insights (Claude API) وخطط تمرين مخصصة |

---

## 15. مصادر للتعلم

- **Apple Documentation**: SwiftUI, SwiftData, HealthKit, WidgetKit, Swift Charts
- **WWDC Sessions**: ابحث عن "SwiftData", "HealthKit", "Meet Swift Testing", "Swift Concurrency"
- **Stanford CS193p**: كورس SwiftUI مجاني على YouTube
- **Hacking with Swift** (Paul Hudson): "100 Days of SwiftUI"
- **Swift.org**: دليل اللغة الرسمي (The Swift Programming Language)
- **Point-Free**: لمواضيع Architecture المتقدمة

---

## ✅ Definition of Done العام للمشروع

- [ ] كل features الـ MVP شغالة ومختبرة على جهاز حقيقي.
- [ ] Test coverage للـ business logic ≥ 70%.
- [ ] مفيش warnings أو crashes في Instruments.
- [ ] دعم عربي/إنجليزي + Dark Mode + Dynamic Type.
- [ ] README ولقطات شاشة على GitHub.
- [ ] Build منشور على TestFlight.

---

*آخر تحديث: أكتوبر 2026*
