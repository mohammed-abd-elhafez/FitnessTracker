import SwiftUI

/// Circular progress indicator. `progress` is clamped to `0...1`.
struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 12

    private var clamped: Double { min(max(progress, 0), 1) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: clamped)
            Text(clamped, format: .percent.precision(.fractionLength(0)))
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityValue(Text(clamped, format: .percent.precision(.fractionLength(0))))
    }
}

#Preview {
    ProgressRing(progress: 0.65)
        .frame(width: 96, height: 96)
        .padding()
}
