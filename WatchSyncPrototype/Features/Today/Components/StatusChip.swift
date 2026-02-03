import SwiftUI

/// Small capsule showing sync status (icon + label) for a metric or workout.
struct StatusChip: View {
    let freshness: Freshness

    private var icon: String {
        switch freshness {
        case .synced: return "checkmark.circle"
        case .pending: return "clock"
        case .partial: return "exclamationmark.triangle"
        case .failed: return "xmark.octagon"
        }
    }

    private var label: String {
        switch freshness {
        case .synced: return "Synced"
        case .pending: return "Pending"
        case .partial: return "Partial"
        case .failed: return "Failed"
        }
    }

    private var foregroundColor: Color {
        switch freshness {
        case .synced: return .green
        case .pending: return .orange
        case .partial: return .orange
        case .failed: return .red
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption2)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(foregroundColor.opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        StatusChip(freshness: .synced)
        StatusChip(freshness: .pending)
        StatusChip(freshness: .partial)
        StatusChip(freshness: .failed)
    }
    .padding()
}
