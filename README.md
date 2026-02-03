# WatchSyncPrototype — Offline-first Today Sync Demo (iOS)

A small SwiftUI prototype that demonstrates **explicit data freshness** (synced / pending / partial / failed),
a deterministic **sync state machine**, and **debuggable observability** for mobile data pipelines.

## Demo
📽️ Watch the 2-minute demo (no setup required):  
https://www.loom.com/share/8b083659498a48fbad73db9f7f9631c3

## What this demonstrates (engineering)
- **Stale-while-revalidate**: UI renders immediately from local snapshot (no blank screens)
- **Freshness modeling**: every metric/workout carries a freshness + source + lastUpdatedAt
- **Deterministic failure handling**:
  - Offline → pending stays pending + backoff logged
  - Auth expired → pending → failed with user-visible reason
  - Recovery → pending → synced
- **Observability**: debug overlay shows sync state, pending counts, and exportable logs

## How to run
1. Open `WatchSyncPrototype.xcodeproj` in Xcode
2. Select an iOS simulator
3. Run (⌘R)

## How to reproduce demo flows
1. Open Simulation Panel (gear icon)
2. Tap **Reset Seed**
3. Tap **Simulate New Workout** → see **Pending**
4. Set **Network: Offline** → **Run Sync Now** → stays pending + offline log
5. Set **Network: Online**, **Auth: Expired** → **Run Sync Now** → becomes failed with note
6. Set **Auth: Valid** → **Simulate New Workout** → **Run Sync Now** → becomes synced

## Architecture (high level)
- `Domain/Models`: Metric/Workout/TodaySnapshot + Freshness + SyncState
- `Data/Local`: InMemoryLocalStore (seed bootstrap)
- `Data/Remote`: MockRemoteAPI (controlled by SimulationConfig)
- `Sync`: SyncStateMachine + RetryPolicy + SyncEngine
- `Observability`: EventLog + Debug Overlay
