import SwiftUI

/// Editable list of exercise sets (strength workouts). Weights display in the chosen unit.
struct WorkoutSetsSection: View {
    @Bindable var viewModel: WorkoutFormViewModel
    @AppStorage(UnitSystem.storageKey) private var unitsRaw = UnitSystem.metric.rawValue

    private var units: UnitSystem { UnitSystem(storedValue: unitsRaw) }

    var body: some View {
        Section("workoutForm.sets") {
            ForEach($viewModel.draft.sets) { $set in
                VStack(alignment: .leading) {
                    TextField("workoutForm.exerciseName", text: $set.name)
                    Stepper("workoutForm.reps \(set.reps)", value: $set.reps, in: 1...100)
                    HStack {
                        TextField("workoutForm.weight", value: weightBinding($set.weightKg), format: .number)
                            .keyboardType(.decimalPad)
                        Text(units.weightUnitTitle).foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { viewModel.removeSets(at: $0) }
            Button("workoutForm.addSet", systemImage: "plus") { viewModel.addSet() }
        }
    }

    /// Bridges stored kilograms to the displayed unit.
    private func weightBinding(_ kilograms: Binding<Double>) -> Binding<Double> {
        let units = units
        return Binding(
            get: { units.weight(fromKilograms: kilograms.wrappedValue) },
            set: { kilograms.wrappedValue = units.kilograms(fromWeight: $0) }
        )
    }
}
