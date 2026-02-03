import SwiftUI

/// Form to control simulation (network, auth, BLE) and trigger sync / reset.
struct SimulationPanelView: View {
    @ObservedObject var simulation: SimulationConfig
    @ObservedObject var viewModel: TodayViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Network") {
                    Picker("Mode", selection: $simulation.networkMode) {
                        ForEach(SimulationConfig.NetworkMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    if simulation.networkMode == .slow {
                        Stepper(
                            "Delay: \(simulation.artificialDelayMs) ms",
                            value: $simulation.artificialDelayMs,
                            in: 200 ... 5000,
                            step: 200
                        )
                    }
                }
                Section("Auth") {
                    Picker("Mode", selection: $simulation.authMode) {
                        ForEach(SimulationConfig.AuthMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("BLE") {
                    Picker("Mode", selection: $simulation.bleMode) {
                        ForEach(SimulationConfig.BLEMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Actions") {
                    Button("Simulate New Workout") {
                        Task { await viewModel.simulateNewWorkout() }
                    }
                    Button("Run Sync Now") {
                        Task { await viewModel.refresh() }
                    }
                    Button("Reset Seed") {
                        Task { await viewModel.resetSeed() }
                    }
                }
            }
            .navigationTitle("Simulation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
