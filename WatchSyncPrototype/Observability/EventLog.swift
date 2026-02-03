import Combine
import Foundation
import SwiftUI

/// A single log entry with id, timestamp, and message.
struct LogEvent: Identifiable {
    let id: UUID
    let timestamp: Date
    let message: String
}

/// In-memory event log for observability (e.g. sync and debug). Keeps last 50 events.
@MainActor
final class EventLog: ObservableObject {
    private static let maxEvents = 50

    @Published private(set) var events: [LogEvent] = []

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm:ss a"
        return f
    }()

    /// Appends a message and trims to the last 50 events.
    func add(_ message: String) {
        let event = LogEvent(id: UUID(), timestamp: Date(), message: message)
        events.append(event)
        if events.count > Self.maxEvents {
            events.removeFirst(events.count - Self.maxEvents)
        }
    }

    /// Formats a date as "h:mm:ss a".
    static func formatTimestamp(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
}
