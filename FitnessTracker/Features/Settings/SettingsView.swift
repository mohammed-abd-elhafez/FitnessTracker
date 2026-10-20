import SwiftUI
import UIKit

/// Settings tab: daily goals, reminder and privacy note.
struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(\.openURL) private var openURL
    @AppStorage(UnitSystem.storageKey) private var unitsRaw = UnitSystem.metric.rawValue

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                goalsSection
                unitsSection
                reminderSection
                languageSection
                Section(footer: Text("settings.privacy.footer")) { EmptyView() }
            }
            .navigationTitle("tab.settings")
            .alert("error.title", isPresented: errorBinding) {
                Button("common.ok", role: .cancel) {}
            } message: {
                Text(verbatim: viewModel.errorMessage ?? "")
            }
        }
        .task { await viewModel.load() }
    }

    private var goalsSection: some View {
        Section("settings.goals") {
            ForEach(GoalKind.allCases, id: \.self) { kind in
                GoalStepperRow(
                    kind: kind,
                    value: viewModel.target(for: kind),
                    onChange: { value in Task { await viewModel.updateTarget(kind, to: value) } }
                )
            }
        }
    }

    private var unitsSection: some View {
        Section("settings.units") {
            Picker("settings.units", selection: $unitsRaw) {
                ForEach(UnitSystem.allCases, id: \.rawValue) { system in
                    Text(system.title).tag(system.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var languageSection: some View {
        Section {
            Button("settings.language") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
        } footer: {
            Text("settings.language.footer")
        }
    }

    private var reminderSection: some View {
        Section {
            Toggle("settings.reminder", isOn: Binding(
                get: { viewModel.preferences.isEnabled },
                set: { enabled in Task { await viewModel.setReminderEnabled(enabled) } }
            ))
            if viewModel.preferences.isEnabled {
                DatePicker("settings.reminder.time", selection: Binding(
                    get: { viewModel.reminderDate },
                    set: { date in Task { await viewModel.setReminderTime(date) } }
                ), displayedComponents: .hourAndMinute)
            }
            if viewModel.permissionDenied {
                Text("settings.reminder.denied").font(.footnote).foregroundStyle(.red)
                Button("settings.openSettings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.dismissError() } })
    }
}
