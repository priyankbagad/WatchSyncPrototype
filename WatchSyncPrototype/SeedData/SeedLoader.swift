import Foundation

/// Loads seed data from the app bundle (e.g. for development or default state).
///
/// SeedLoader is intentionally not `@MainActor`-isolated so it can be called from any actor
/// (e.g. `InMemoryLocalStore`) without hopping to the main actor. It only does synchronous
/// file read and JSON decode with no UI or main-actor state.
enum SeedLoader {
    private static let seedFileName = "seed_today"
    private static let seedFileExtension = "json"

    /// Builds a `JSONDecoder` that decodes ISO8601 date strings (with or without fractional seconds).
    private static var iso8601Decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "UTC") ?? .current
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.formatOptions = [.withInternetDateTime]
            guard let fallback = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid ISO8601 date string: \(dateString)"
                )
            }
            return fallback
        }
        return decoder
    }

    /// Loads and decodes `seed_today.json` from the app bundle into a `TodaySnapshot`.
    /// Callable from any isolation context (e.g. from an actor) so stores can seed without MainActor.
    /// - Returns: Decoded snapshot.
    /// - Throws: `SeedLoader.Error` if the file is missing or decoding fails.
    static nonisolated func loadTodaySeed() throws -> TodaySnapshot {
        let name = "seed_today"
        let ext = "json"
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw Error.fileNotFound(name: "\(name).\(ext)")
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw Error.cannotReadFile(url: url, underlying: error)
        }
        let decoder: JSONDecoder = {
            let d = JSONDecoder()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            formatter.timeZone = TimeZone(identifier: "UTC") ?? .current
            d.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                if let date = formatter.date(from: dateString) {
                    return date
                }
                formatter.formatOptions = [.withInternetDateTime]
                guard let fallback = formatter.date(from: dateString) else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Invalid ISO8601 date string: \(dateString)"
                    )
                }
                return fallback
            }
            return d
        }()
        do {
            return try decoder.decode(TodaySnapshot.self, from: data)
        } catch let error as DecodingError {
            let context = Self.decodeContext(from: error)
            throw Error.decodeFailed(context: context, underlying: error)
        } catch {
            throw Error.decodeFailed(context: nil, underlying: error)
        }
    }

    /// Builds a human-readable context string from a `DecodingError`. Used only from nonisolated `loadTodaySeed()`.
    private static nonisolated func decodeContext(from error: DecodingError) -> String? {
        switch error {
        case .keyNotFound(let key, let context):
            return "Missing key '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .typeMismatch(let type, let context):
            return "Type mismatch (\(type)) at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Value not found (\(type)) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .dataCorrupted(let context):
            return "Data corrupted at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        @unknown default:
            return nil
        }
    }
}

// MARK: - Errors

extension SeedLoader {
    enum Error: Swift.Error, LocalizedError {
        case fileNotFound(name: String)
        case cannotReadFile(url: URL, underlying: Swift.Error)
        case decodeFailed(context: String?, underlying: Swift.Error)

        var errorDescription: String? {
            switch self {
            case .fileNotFound(let name):
                return "Seed file not found in bundle: \(name)"
            case .cannotReadFile(let url, let underlying):
                return "Cannot read seed file at \(url.path): \(underlying.localizedDescription)"
            case .decodeFailed(let context?, let underlying):
                return "Failed to decode seed JSON — \(context). \(underlying.localizedDescription)"
            case .decodeFailed(_, let underlying):
                return "Failed to decode seed JSON: \(underlying.localizedDescription)"
            }
        }
    }
}
