import Foundation

/// Publishes today's summary to the widget.
protocol SnapshotPublishing: Sendable {
    func publish(_ snapshot: DailySnapshot)
}
