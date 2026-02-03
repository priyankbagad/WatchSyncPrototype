import Foundation

/// Mock remote API that uses SimulationConfig to simulate offline, slow, and auth-expired behavior.
struct MockRemoteAPI: RemoteAPI {
    private let simulation: SimulationConfig

    init(simulation: SimulationConfig) {
        self.simulation = simulation
    }

    func fetchToday(current: TodaySnapshot) async throws -> TodaySnapshot {
        if simulation.networkMode == .offline {
            throw NetworkError.offline
        }
        if simulation.authMode == .expired {
            throw AuthError.expired
        }
        if simulation.networkMode == .slow {
            let ms = simulation.artificialDelayMs
            try await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
        }

        var snapshot = current
        let now = Date()
        snapshot.lastUpdatedAt = now
        snapshot.source = "remote"
        snapshot.freshness = .synced

        snapshot.metrics = snapshot.metrics.map { metric in
            var m = metric
            m.lastUpdatedAt = now
            if m.freshness == .pending {
                m.freshness = .synced
                m.note = nil
            } else if m.freshness == .partial {
                m.lastUpdatedAt = now
            }
            return m
        }
        snapshot.workouts = snapshot.workouts.map { workout in
            var w = workout
            w.lastUpdatedAt = now
            if w.freshness == .pending {
                w.freshness = .synced
                w.note = nil
            }
            return w
        }
        return snapshot
    }

    func uploadPendingWorkouts(_ workouts: [Workout]) async throws {
        if simulation.networkMode == .offline {
            throw NetworkError.offline
        }
        if simulation.authMode == .expired {
            throw AuthError.expired
        }
        if simulation.networkMode == .slow {
            let ms = simulation.artificialDelayMs
            try await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
        }
        // Simulate success; no-op.
    }
}
