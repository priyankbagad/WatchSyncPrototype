import Foundation

/// A single health/fitness metric (e.g. steps, heart rate).
struct Metric: Codable, Identifiable {
    let id: UUID
    var name: String
    var value: Double
    var unit: String

    // Sync/metadata
    var freshness: Freshness
    var source: String
    var lastUpdatedAt: Date
    /// Optional note or error message (e.g. when freshness is failed or partial).
    var note: String?

    init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        unit: String,
        freshness: Freshness = .synced,
        source: String = "local",
        lastUpdatedAt: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.unit = unit
        self.freshness = freshness
        self.source = source
        self.lastUpdatedAt = lastUpdatedAt
        self.note = note
    }
}
