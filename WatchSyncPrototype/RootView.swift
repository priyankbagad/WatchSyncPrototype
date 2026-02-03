//
//  ContentView.swift
//  WatchSyncPrototype
//
//  Created by Priyank Bagad on 2/3/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: TodayViewModel

    init() {
        let store = InMemoryLocalStore()
        let simulation = SimulationConfig()
        let log = EventLog()
        _viewModel = StateObject(wrappedValue: TodayViewModel(store: store, simulation: simulation, log: log))
    }

    var body: some View {
        TodayTimelineView(viewModel: viewModel)
            .task {
                await viewModel.load()
            }
    }
}

#Preview {
    RootView()
}
