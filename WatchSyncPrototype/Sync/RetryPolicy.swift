import Foundation

/// Backoff for retries: min(2^n, 30) seconds.
struct RetryPolicy {
    /// Returns delay in seconds for the given zero-based failure count.
    func nextDelaySeconds(failureCount: Int) -> Double {
        let seconds = pow(2.0, Double(failureCount))
        return min(seconds, 30)
    }
}
