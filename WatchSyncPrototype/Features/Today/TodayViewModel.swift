import Combine
import Foundation
import SwiftUI

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var snapshot: TodaySnapshot?
    @Published var lastUpdatedText: String = ""
    @Published var errorMessage: String?
    @Published var syncStateText: String = "idle"

    private let store: any LocalStore
    let simulation: SimulationConfig
    let log: EventLog
    let syncEngine: SyncEngine
    private var cancellables = Set<AnyCancellable>()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f
    }()

    init(store: any LocalStore, simulation: SimulationConfig, log: EventLog) {
        self.store = store
        self.simulation = simulation
        self.log = log
        let api = MockRemoteAPI(simulation: simulation)
        self.syncEngine = SyncEngine(store: store, api: api, log: log)
        syncEngine.$syncState
            .receive(on: RunLoop.main)
            .map { "\($0)" }
            .sink { [weak self] text in self?.syncStateText = text }
            .store(in: &cancellables)
        syncStateText = "\(syncEngine.syncState)"
    }

    func load() async {
        do {
            try await store.seedIfNeeded()
            let snap = await store.getToday()
            snapshot = snap
            lastUpdatedText = snap.flatMap { Self.dateFormatter.string(from: $0.lastUpdatedAt) } ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await syncEngine.syncNow()
        let snap = await store.getToday()
        snapshot = snap
        lastUpdatedText = snap.flatMap { Self.dateFormatter.string(from: $0.lastUpdatedAt) } ?? ""
    }

    func simulateNewWorkout() async {
        guard var snap = await store.getToday() else { return }
        let workout = Workout(
            activityType: "Simulated",
            startDate: Date(),
            durationSeconds: 900,
            freshness: .pending,
            source: "local",
            lastUpdatedAt: Date(),
            note: "Upload queued."
        )
        snap.workouts.append(workout)
        await store.saveToday(snap)
        snapshot = await store.getToday()
        lastUpdatedText = snapshot.flatMap { Self.dateFormatter.string(from: $0.lastUpdatedAt) } ?? ""
    }

    func resetSeed() async {
        do {
            let seed = try SeedLoader.loadTodaySeed()
            await store.saveToday(seed)
            snapshot = await store.getToday()
            lastUpdatedText = snapshot.flatMap { Self.dateFormatter.string(from: $0.lastUpdatedAt) } ?? ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
