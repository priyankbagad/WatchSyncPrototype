import Foundation

/// Remote API for fetching and uploading today data. Conforming types are Sendable so they can be used across isolation boundaries.
protocol RemoteAPI: Sendable {
    func fetchToday(current: TodaySnapshot) async throws -> TodaySnapshot
    func uploadPendingWorkouts(_ workouts: [Workout]) async throws
}

// MARK: - Errors

enum NetworkError: Error {
    case offline
}

enum AuthError: Error {
    case expired
}

enum BLEError: Error {
    case unavailable
}
