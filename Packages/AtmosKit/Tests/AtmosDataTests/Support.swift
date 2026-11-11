@testable import AtmosData
import Foundation

/// Reads a recorded API response from docs/api/samples, the same files the API contract links
/// to: one source of truth. Located through this file's own path, so it works with
/// `swift test` and Xcode alike, on any platform.
enum Samples {
    static func data(_ name: String) throws -> Data {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { url.deleteLastPathComponent() } // → repository root
        return try Data(contentsOf: url.appendingPathComponent("docs/api/samples/\(name)"))
    }
}

/// Replays queued responses and records every URL requested.
actor FakeHTTPClient: HTTPClient {
    enum Reply {
        case response(Data, Int)
        case failure(any Error)
    }

    private var replies: [Reply]
    private(set) var requested: [URL] = []

    init(_ replies: [Reply]) {
        self.replies = replies
    }

    func get(_ url: URL) async throws -> (data: Data, statusCode: Int) {
        requested.append(url)
        guard !replies.isEmpty else { throw URLError(.notConnectedToInternet) }
        switch replies.removeFirst() {
        case let .response(data, status): return (data, status)
        case let .failure(error): throw error
        }
    }
}

extension URL {
    func query(_ name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == name }?.value
    }
}

/// A fresh, empty folder for one test.
func temporaryDirectory() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent("atmos-tests-\(UUID().uuidString)")
}
