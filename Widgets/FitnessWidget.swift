import SwiftUI
import WidgetKit

// Widget extension sources. Create the target in Xcode (see docs/RELEASE.md), then add:
//   Widgets/*, Domain/Entities/DailySnapshot.swift, Domain/UseCases/GoalProgress.swift,
//   Core/Utilities/AppGroup.swift, Core/Utilities/Logger+App.swift,
//   Data/Widgets/AppGroupSnapshotStore.swift, Core/DesignSystem/ProgressRing.swift,
//   Resources/Localizable.xcstrings

struct FitnessEntry: TimelineEntry {
    let date: Date
    let snapshot: DailySnapshot
}

struct FitnessProvider: TimelineProvider {
    private let store = AppGroupSnapshotStore()

    func placeholder(in context: Context) -> FitnessEntry {
        FitnessEntry(date: .now, snapshot: DailySnapshot(date: .now, steps: 6_500, stepGoal: 10_000,
                                                         calories: 300, calorieGoal: 500))
    }

    func getSnapshot(in context: Context, completion: @escaping (FitnessEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FitnessEntry>) -> Void) {
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry()], policy: .after(refresh)))
    }

    private func entry() -> FitnessEntry {
        let snapshot = store.read()
        let isToday = snapshot.map { Calendar.current.isDateInToday($0.date) } ?? false
        return FitnessEntry(date: .now, snapshot: isToday ? (snapshot ?? .empty) : .empty)
    }
}

struct FitnessWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FitnessEntry

    var body: some View {
        switch family {
        case .systemMedium:
            HStack(spacing: 24) {
                ring
                VStack(alignment: .leading, spacing: 8) {
                    metric("today.steps", entry.snapshot.steps.formatted())
                    metric("today.calories", Int(entry.snapshot.calories).formatted())
                }
                Spacer()
            }
        default:
            VStack(spacing: 6) {
                ring
                Text(entry.snapshot.steps.formatted()).font(.headline).monospacedDigit()
            }
        }
    }

    private var ring: some View {
        ProgressRing(progress: entry.snapshot.stepFraction, lineWidth: 10)
            .frame(width: 72, height: 72)
            .accessibilityLabel(Text("today.steps"))
    }

    private func metric(_ title: LocalizedStringKey, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.weight(.semibold)).monospacedDigit()
        }
    }
}

@main
struct FitnessWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FitnessWidget", provider: FitnessProvider()) { entry in
            FitnessWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("today.title")
        .description("widget.description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
