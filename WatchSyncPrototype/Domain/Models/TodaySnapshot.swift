import Foundation

/// Snapshot of today’s metrics and workouts (e.g. for the “today” screen).
struct TodaySnapshot: Codable, Identifiable {
    let id: UUID
    var date: Date
    var metrics: [Metric]
    var workouts: [Workout]

    // Sync/metadata
    var freshness: Freshness
    var source: String
    var lastUpdatedAt: Date
    /// Optional note or error message (e.g. when freshness is failed or partial).
    var note: String?

    init(
        id: UUID = UUID(),
        date: Date = Calendar.current.startOfDay(for: Date()),
        metrics: [Metric] = [],
        workouts: [Workout] = [],
        freshness: Freshness = .synced,
        source: String = "local",
        lastUpdatedAt: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.metrics = metrics
        self.workouts = workouts
        self.freshness = freshness
        self.source = source
        self.lastUpdatedAt = lastUpdatedAt
        self.note = note
    }
}
