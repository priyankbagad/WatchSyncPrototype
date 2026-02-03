import Foundation

/// Persistent or in-memory store for today’s snapshot (metrics and workouts).
protocol LocalStore: Sendable {
    /// Returns whether the store has no snapshot (e.g. never seeded).
    func isEmpty() async -> Bool

    /// Returns the current today snapshot, or `nil` if none.
    func getToday() async -> TodaySnapshot?

    /// Replaces the stored today snapshot with the given one.
    func saveToday(_ snapshot: TodaySnapshot) async

    /// If the store is empty, loads the seed and saves it; otherwise no-op.
    /// - Throws: If loading or decoding the seed fails.
    func seedIfNeeded() async throws
}
