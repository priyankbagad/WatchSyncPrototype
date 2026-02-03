import Foundation

/// A single workout session.
struct Workout: Codable, Identifiable {
    let id: UUID
    var activityType: String
    var startDate: Date
    var durationSeconds: Double

    // Sync/metadata
    var freshness: Freshness
    var source: String
    var lastUpdatedAt: Date
    /// Optional note or error message (e.g. when freshness is failed or partial).
    var note: String?

    init(
        id: UUID = UUID(),
        activityType: String,
        startDate: Date,
        durationSeconds: Double,
        freshness: Freshness = .synced,
        source: String = "local",
        lastUpdatedAt: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.activityType = activityType
        self.startDate = startDate
        self.durationSeconds = durationSeconds
        self.freshness = freshness
        self.source = source
        self.lastUpdatedAt = lastUpdatedAt
        self.note = note
    }
}
