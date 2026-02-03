import Foundation

/// Deterministic state machine for sync: idle ↔ syncing, backingOff, authExpired.
struct SyncStateMachine {
    var state: SyncState = .idle

    enum Event {
        case start
        case success
        case networkFailure
        case authExpired
    }

    mutating func transition(event: Event) {
        switch (state, event) {
        case (.idle, .start):
            state = .syncing
        case (.syncing, .success):
            state = .idle
        case (.syncing, .networkFailure):
            state = .backingOff
        case (.syncing, .authExpired):
            state = .authExpired
        case (.backingOff, .success):
            state = .idle
        case (.authExpired, .success):
            state = .idle
        default:
            break
        }
    }
}
