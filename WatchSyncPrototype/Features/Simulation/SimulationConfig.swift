import Combine
import Foundation
import SwiftUI

/// Simulation toggles for network, auth, and BLE (e.g. for development and testing).
/// Marked @unchecked Sendable so mocks (e.g. MockRemoteAPI) can hold a reference and remain Sendable.
final class SimulationConfig: ObservableObject, @unchecked Sendable {
    enum NetworkMode: String, CaseIterable {
        case online
        case slow
        case offline
    }

    enum AuthMode: String, CaseIterable {
        case valid
        case expired
    }

    enum BLEMode: String, CaseIterable {
        case available
        case unavailable
    }

    @Published var networkMode: NetworkMode = .online
    @Published var authMode: AuthMode = .valid
    @Published var bleMode: BLEMode = .available
    /// Delay in milliseconds when `networkMode == .slow`.
    @Published var artificialDelayMs: Int = 1200
}
