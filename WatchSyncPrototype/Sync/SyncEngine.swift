import Combine
import Foundation
import SwiftUI

/// Coordinates sync with local store and remote API; updates sync state and event log.
@MainActor
final class SyncEngine: ObservableObject {
    @Published private(set) var syncState: SyncState = .idle

    private let store: any LocalStore
    private let api: RemoteAPI
    private let log: EventLog
    private let retryPolicy = RetryPolicy()
    private var failureCount = 0
    private var stateMachine = SyncStateMachine()

    init(store: any LocalStore, api: RemoteAPI, log: EventLog) {
        self.store = store
        self.api = api
        self.log = log
    }

    func syncNow() async {
        log.add("Sync started")
        stateMachine.transition(event: .start)
        syncState = stateMachine.state

        guard let current = await store.getToday() else {
            syncState = .idle
            return
        }

        do {
            let updated = try await api.fetchToday(current: current)
            failureCount = 0
            await store.saveToday(updated)
            stateMachine.transition(event: .success)
            syncState = stateMachine.state
            log.add("Sync success")
        } catch is NetworkError {
            failureCount += 1
            stateMachine.transition(event: .networkFailure)
            syncState = stateMachine.state
            let delay = retryPolicy.nextDelaySeconds(failureCount: failureCount - 1)
            log.add("Offline; backoff \(Int(delay))s")
            stateMachine.transition(event: .success)
            syncState = stateMachine.state
        } catch is AuthError {
            stateMachine.transition(event: .authExpired)
            syncState = stateMachine.state
            log.add("Auth expired")
            var snapshot = current
            for i in snapshot.workouts.indices {
                if snapshot.workouts[i].freshness == .pending {
                    snapshot.workouts[i].freshness = .failed
                    snapshot.workouts[i].note = "Auth expired. Please re-login."
                }
            }
            await store.saveToday(snapshot)
            stateMachine.transition(event: .success)
            syncState = stateMachine.state
        } catch {
            log.add("Sync failed: \(error.localizedDescription)")
            syncState = .idle
        }
    }
}
