import Foundation

/// Stores `Codable` values as JSON files in one directory (ADR-0007). An `actor`, so two
/// tasks can never write the same file at the same time.
actor JSONFileStore {
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// `directory` is created if needed. The app uses Application Support; tests use a
    /// temporary folder.
    init(directory: URL) {
        self.directory = directory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    /// The stored value, or `nil` if there is none **or it cannot be read** (for example after
    /// an app update changed the format): an unreadable cache is "no cache", never a crash.
    func read<Value: Decodable>(_ type: Value.Type, key: String) -> Value? {
        guard let data = try? Data(contentsOf: url(for: key)) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    func write<Value: Encodable>(_ value: Value, key: String) throws {
        try encoder.encode(value).write(to: url(for: key), options: .atomic)
    }

    private func url(for key: String) -> URL {
        // Keys are built by the app ("forecast-41.01,28.97"); keep file names safe anyway.
        let safe = key.map { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "." ? $0 : "_" }
        return directory.appendingPathComponent(String(safe) + ".json")
    }
}
