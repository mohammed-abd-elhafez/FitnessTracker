import SwiftUI

/// One row in the workout history list.
struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        HStack {
            Label(workout.type.title, systemImage: workout.type.systemImage)
                .font(.headline)
            Spacer()
            VStack(alignment: .trailing) {
                Text(Measurement(value: Double(workout.durationMinutes), unit: UnitDuration.minutes)
                    .formatted(.measurement(
                        width: .abbreviated,
                        numberFormatStyle: .number.precision(.fractionLength(0))
                    )))
                    .font(.subheadline)
                if let calories = workout.caloriesBurned {
                    Text(Measurement(value: calories, unit: UnitEnergy.kilocalories)
                        .formatted(.measurement(
                            width: .abbreviated,
                            numberFormatStyle: .number.precision(.fractionLength(0))
                        )))
                        .font(.caption)
                }
                Text(workout.startDate, format: .dateTime.day().month().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
