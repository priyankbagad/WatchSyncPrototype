import Foundation

/// High-level state of the sync engine (UI/domain only; not Codable).
enum SyncState {
    /// No sync in progress.
    case idle
    /// Sync is currently running.
    case syncing
    /// Sync is waiting before retry (e.g. after transient failure).
    case backingOff
    /// Auth is expired; user must re-authenticate.
    case authExpired
}
