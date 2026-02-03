import SwiftUI
import UIKit

/// Debug overlay: sync state, last updated, pending count, event log, copy logs.
struct DebugOverlayView: View {
    @ObservedObject var viewModel: TodayViewModel
    @ObservedObject var syncEngine: SyncEngine
    @ObservedObject var log: EventLog

    private var pendingCount: Int {
        guard let snap = viewModel.snapshot else { return 0 }
        let m = snap.metrics.filter { $0.freshness == .pending }.count
        let w = snap.workouts.filter { $0.freshness == .pending }.count
        return m + w
    }

    var body: some View {
        NavigationStack {
            List {
                Section("State") {
                    LabeledContent("Sync", value: viewModel.syncStateText)
                    LabeledContent("Last updated", value: viewModel.lastUpdatedText.isEmpty ? "—" : viewModel.lastUpdatedText)
                    LabeledContent("Pending", value: "\(pendingCount)")
                }
                Section("Events") {
                    ForEach(log.events.reversed()) { event in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.message)
                                .font(.subheadline)
                            Text(EventLog.formatTimestamp(event.timestamp))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Copy Logs") {
                        let text = log.events
                            .reversed()
                            .map { "\(EventLog.formatTimestamp($0.timestamp)) \($0.message)" }
                            .joined(separator: "\n")
                        UIPasteboard.general.string = text
                    }
                }
            }
        }
    }
}
