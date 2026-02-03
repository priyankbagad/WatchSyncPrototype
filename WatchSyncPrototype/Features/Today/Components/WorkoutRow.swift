import SwiftUI

/// Row for a single workout: activity type, duration, status chip, optional note.
struct WorkoutRow: View {
    let workout: Workout

    private var durationText: String {
        let minutes = Int(workout.durationSeconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }

    private var showNote: Bool {
        (workout.freshness == .failed || workout.freshness == .partial) && workout.note != nil && !(workout.note?.isEmpty ?? true)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.activityType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(durationText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                StatusChip(freshness: workout.freshness)
            }
            if showNote, let note = workout.note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 0)
    }
}

#Preview {
    List {
        WorkoutRow(workout: Workout(
            activityType: "Running",
            startDate: Date(),
            durationSeconds: 1800,
            freshness: .synced
        ))
        WorkoutRow(workout: Workout(
            activityType: "Strength",
            startDate: Date(),
            durationSeconds: 2700,
            freshness: .failed,
            note: "Auth expired. Please re-login."
        ))
    }
}
