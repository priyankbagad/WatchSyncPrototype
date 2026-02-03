import SwiftUI

/// Rounded card showing a metric name, value + unit, and sync status.
struct MetricCard: View {
    let metric: Metric

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metric.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                StatusChip(freshness: metric.freshness)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(valueText)
                    .font(.title2)
                    .fontWeight(.semibold)
                if !metric.unit.isEmpty {
                    Text(metric.unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var valueText: String {
        if metric.value == floor(metric.value) {
            return String(format: "%.0f", metric.value)
        }
        return String(format: "%.1f", metric.value)
    }
}

#Preview {
    MetricCard(metric: Metric(
        name: "Recovery",
        value: 72,
        unit: "%",
        freshness: .synced
    ))
    .padding()
}
