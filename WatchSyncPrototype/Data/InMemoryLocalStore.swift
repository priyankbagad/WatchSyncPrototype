import Foundation

/// In-memory implementation of `LocalStore` (e.g. for development or testing).
actor InMemoryLocalStore: LocalStore {
    private var today: TodaySnapshot?

    func isEmpty() async -> Bool {
        today == nil
    }

    func getToday() async -> TodaySnapshot? {
        today
    }

    func saveToday(_ snapshot: TodaySnapshot) async {
        today = snapshot
    }

    func seedIfNeeded() async throws {
        if today == nil {
            let seed = try SeedLoader.loadTodaySeed()
            today = seed
        }
    }
}
