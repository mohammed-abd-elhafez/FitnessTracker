import Charts
import SwiftUI

/// Bar chart of daily steps with an optional goal line.
struct StepsChart: View {
    let points: [DailyStepsPoint]
    let goal: Double?

    var body: some View {
        Chart {
            ForEach(points) { point in
                BarMark(
                    x: .value("progress.axis.date", point.date, unit: .day),
                    y: .value("today.steps", point.steps)
                )
                .foregroundStyle(Color.accentColor)
            }
            if let goal {
                RuleMark(y: .value("progress.goal", goal))
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
        }
        .frame(height: 240)
        .accessibilityChartDescriptor(StepsChartDescriptor(points: points))
    }
}
