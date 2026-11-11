import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking // URLSession on Linux
#endif

/// The smallest thing the data layer needs from the network: send a request, get bytes and a
/// status code back. A protocol, so tests can replay the recorded API responses without a
/// network, on any platform.
protocol HTTPClient: Sendable {
    func get(_ url: URL) async throws -> (data: Data, statusCode: Int)
}

/// The real client, on `URLSession`, with the rules from API_CONTRACT §4.
struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let userAgent: String

    init(userAgent: String) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15 // read timeout
        configuration.timeoutIntervalForResource = 30
        session = URLSession(configuration: configuration)
        self.userAgent = userAgent
    }

    func get(_ url: URL) async throws -> (data: Data, statusCode: Int) {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        return (data, (response as? HTTPURLResponse)?.statusCode ?? 0)
    }
}

/// Retries network errors and HTTP 5xx with exponential back-off: wait `baseDelay`, then
/// twice that (API_CONTRACT §4). HTTP 4xx is **not** retried: our request is wrong, and
/// sending it again will not help. Cancellation is never retried.
struct RetryingHTTPClient: HTTPClient {
    private let wrapped: any HTTPClient
    private let maxRetries: Int
    private let baseDelay: Duration
    private let sleep: @Sendable (Duration) async throws -> Void

    init(
        wrapping wrapped: any HTTPClient,
        maxRetries: Int = 2,
        baseDelay: Duration = .seconds(1),
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.wrapped = wrapped
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.sleep = sleep
    }

    func get(_ url: URL) async throws -> (data: Data, statusCode: Int) {
        var attempt = 0
        while true {
            do {
                let response = try await wrapped.get(url)
                if response.statusCode < 500 || attempt >= maxRetries { return response }
            } catch let error as URLError where error.code != .cancelled && attempt < maxRetries {
                // a network error: retry below
            }
            try await sleep(baseDelay * (1 << attempt))
            attempt += 1
        }
    }
}
