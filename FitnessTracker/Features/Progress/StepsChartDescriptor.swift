import Accessibility
import Foundation
import SwiftUI

/// VoiceOver audio-graph description of the steps chart.
struct StepsChartDescriptor: AXChartDescriptorRepresentable {
    let points: [DailyStepsPoint]

    private func label(_ point: DailyStepsPoint) -> String {
        point.date.formatted(.dateTime.month().day())
    }

    func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXCategoricalDataAxisDescriptor(
            title: String(localized: "progress.axis.date"),
            categoryOrder: points.map(label)
        )
        let maxSteps = Double(points.map(\.steps).max() ?? 0)
        let yAxis = AXNumericDataAxisDescriptor(
            title: String(localized: "today.steps"),
            range: 0...max(maxSteps, 1),
            gridlinePositions: []
        ) { Int($0).formatted() }
        let series = AXDataSeriesDescriptor(
            name: String(localized: "today.steps"),
            isContinuous: false,
            dataPoints: points.map { AXDataPoint(x: label($0), y: Double($0.steps)) }
        )
        return AXChartDescriptor(
            title: String(localized: "progress.chart.title"),
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }

    func updateChartDescriptor(_ descriptor: AXChartDescriptor) {}
}
