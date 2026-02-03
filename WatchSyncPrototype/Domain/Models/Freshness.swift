import Foundation

/// Indicates how up-to-date a piece of data is with respect to sync.
enum Freshness: String, Codable {
    /// Data is in sync with the remote source.
    case synced
    /// Changes are pending upload.
    case pending
    /// Only part of the data could be synced.
    case partial
    /// Sync failed for this data.
    case failed
}
