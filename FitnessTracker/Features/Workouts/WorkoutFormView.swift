import SwiftUI

/// Add/edit workout form presented as a sheet.
struct WorkoutFormView: View {
    @State private var viewModel: WorkoutFormViewModel
    @Environment(\.dismiss) private var dismiss
    private let onSaved: () -> Void

    init(viewModel: WorkoutFormViewModel, onSaved: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                if viewModel.draft.type == .strength {
                    WorkoutSetsSection(viewModel: viewModel)
                }
                errorsSection
            }
            .navigationTitle(viewModel.isEditing ? "workoutForm.editTitle" : "workoutForm.addTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") { Task { await save() } }
                        .disabled(viewModel.isSaving)
                }
            }
        }
    }

    private var detailsSection: some View {
        Section {
            Picker("workoutForm.type", selection: $viewModel.draft.type) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    Label(type.title, systemImage: type.systemImage).tag(type)
                }
            }
            DatePicker("workoutForm.date", selection: $viewModel.draft.startDate)
            Stepper("workoutForm.duration \(viewModel.draft.durationMinutes)",
                    value: $viewModel.draft.durationMinutes, in: 1...1_440, step: 5)
            TextField("workoutForm.calories", value: $viewModel.draft.caloriesBurned, format: .number)
                .keyboardType(.decimalPad)
            TextField("workoutForm.notes", text: $viewModel.notesText, axis: .vertical)
        }
    }

    @ViewBuilder
    private var errorsSection: some View {
        if !viewModel.errors.isEmpty || viewModel.saveError != nil {
            Section {
                ForEach(viewModel.errors, id: \.self) { error in
                    Text(error.message).foregroundStyle(.red)
                }
                if let saveError = viewModel.saveError {
                    Text(verbatim: saveError).foregroundStyle(.red)
                }
            }
        }
    }

    private func save() async {
        if await viewModel.save() {
            onSaved()
            dismiss()
        }
    }
}
