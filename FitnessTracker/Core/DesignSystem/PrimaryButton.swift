import SwiftUI

/// Prominent full-width action button.
struct PrimaryButton: View {
    let title: LocalizedStringKey
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isDisabled)
    }
}

#Preview {
    PrimaryButton(title: "common.save") {}
        .padding()
}
