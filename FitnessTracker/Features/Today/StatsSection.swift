import SwiftUI

/// Daily stat cards plus the most recent workout.
struct StatsSection: View {
    let viewModel: DashboardViewModel
    @AppStorage(UnitSystem.storageKey) private var unitsRaw = UnitSystem.metric.rawValue

    private var units: UnitSystem { UnitSystem(storedValue: unitsRaw) }

    var body: some View {
        VStack(spacing: 12) {
            StatCard(title: "today.steps", value: viewModel.steps.formatted(), systemImage: "figure.walk")
            StatCard(title: "today.distance", value: units.distanceText(meters: viewModel.distanceMeters),
                     systemImage: "map")
            StatCard(title: "today.calories", value: energyText, systemImage: "flame")
            StatCard(title: "today.activeMinutes", value: minutesText, systemImage: "timer")
            lastWorkoutCard
        }
    }

    private var energyText: String {
        Measurement(value: viewModel.calories, unit: UnitEnergy.kilocalories)
            .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(0))))
    }

    private var minutesText: String {
        Measurement(value: Double(viewModel.workoutMinutes), unit: UnitDuration.minutes)
            .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(0))))
    }

    @ViewBuilder
    private var lastWorkoutCard: some View {
        if let workout = viewModel.lastWorkout {
            HStack {
                Label(workout.type.title, systemImage: workout.type.systemImage)
                Spacer()
                Text(workout.startDate, style: .date).foregroundStyle(.secondary)
            }
            .font(.headline)
            .padding(16)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .combine)
        } else {
            Text("today.noWorkout").font(.subheadline).foregroundStyle(.secondary)
        }
    }
}
