import SwiftUI

/// Today screen: metrics (Recovery, Sleep, Strain) and workouts from local store.
struct TodayTimelineView: View {
    @ObservedObject var viewModel: TodayViewModel
    @State private var showDebug = false

    /// WHOOP-like order: Recovery → Sleep → Strain; then rest by name.
    private static let metricOrder = ["recovery", "sleep", "strain"]

    private func orderedMetrics(_ metrics: [Metric]) -> [Metric] {
        let byKey: [String: Metric] = Dictionary(
            uniqueKeysWithValues: metrics.map { (key: $0.name.lowercased(), value: $0) }
        )
        var ordered: [Metric] = []
        for key in Self.metricOrder {
            if let m = byKey[key] {
                ordered.append(m)
            }
        }
        let remaining = metrics.filter { !Self.metricOrder.contains($0.name.lowercased()) }
        ordered.append(contentsOf: remaining.sorted { $0.name.localizedCompare($1.name) == .orderedAscending })
        return ordered
    }

    var body: some View {
        NavigationStack {
            Group {
                if let snapshot = viewModel.snapshot {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if let msg = viewModel.errorMessage {
                                Text(msg)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.horizontal)
                            }
                            if !snapshot.metrics.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Metrics")
                                        .font(.headline)
                                    VStack(spacing: 10) {
                                        ForEach(orderedMetrics(snapshot.metrics)) { metric in
                                            MetricCard(metric: metric)
                                        }
                                    }
                                }
                            }
                            if !snapshot.workouts.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Workouts")
                                        .font(.headline)
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(snapshot.workouts) { workout in
                                            WorkoutRow(workout: workout)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else if viewModel.errorMessage != nil {
                    ContentUnavailableView(
                        "Unable to load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(viewModel.errorMessage ?? "")
                    )
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Today")
                            .font(.headline)
                        Text("Last updated: \(viewModel.lastUpdatedText.isEmpty ? "—" : viewModel.lastUpdatedText)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onLongPressGesture {
                        showDebug = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        NavigationLink(destination: DebugOverlayView(
                            viewModel: viewModel,
                            syncEngine: viewModel.syncEngine,
                            log: viewModel.log
                        )) {
                            Image(systemName: "ladybug")
                        }
                        NavigationLink(destination: SimulationPanelView(
                            simulation: viewModel.simulation,
                            viewModel: viewModel
                        )) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .sheet(isPresented: $showDebug) {
                DebugOverlayView(
                    viewModel: viewModel,
                    syncEngine: viewModel.syncEngine,
                    log: viewModel.log
                )
            }
        }
    }
}

#Preview {
    let sim = SimulationConfig()
    let log = EventLog()
    let vm = TodayViewModel(store: InMemoryLocalStore(), simulation: sim, log: log)
    return TodayTimelineView(viewModel: vm)
        .task { await vm.load() }
}
