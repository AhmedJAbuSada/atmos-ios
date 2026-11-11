@testable import AtmosData
import AtmosDomain
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing

@Suite("Error mapping")
struct ErrorMappingTests {
    @Test("network errors map to domain errors", arguments: [
        (URLError.Code.timedOut, DomainError.timeout),
        (.notConnectedToInternet, .noConnection),
        (.cannotFindHost, .noConnection),
        (.cancelled, .cancelled)
    ])
    func urlErrors(code: URLError.Code, expected: DomainError) {
        #expect(DomainError.from(URLError(code)) == expected)
    }

    @Test("HTTP errors keep their status code; 404 is not found")
    func http() {
        #expect(DomainError.from(HTTPStatusError(code: 400)) == .server(code: 400))
        #expect(DomainError.from(HTTPStatusError(code: 503)) == .server(code: 503))
        #expect(DomainError.from(HTTPStatusError(code: 404)) == .notFound)
    }

    @Test("task cancellation is never reported as offline (ADR-0009)")
    func cancellation() {
        #expect(DomainError.from(CancellationError()) == .cancelled)
    }

    @Test("a broken response maps to unknown")
    func broken() {
        #expect(DomainError.from(InvalidResponseError(reason: "no current")) == .unknown)
    }
}

@Suite("RetryingHTTPClient")
struct RetryingHTTPClientTests {
    let url = URL(literal: "https://example.com")
    let ok = FakeHTTPClient.Reply.response(Data(), 200)

    actor Delays {
        var values: [Duration] = []
        func record(_ value: Duration) { values.append(value) }
    }

    @Test("5xx is retried twice with doubling back-off, then succeeds")
    func serverErrors() async throws {
        let fake = FakeHTTPClient([.response(Data(), 503), .response(Data(), 500), ok])
        let delays = Delays()
        let client = RetryingHTTPClient(wrapping: fake, sleep: { await delays.record($0) })

        #expect(try await client.get(url).statusCode == 200)
        #expect(await delays.values == [.seconds(1), .seconds(2)])
    }

    @Test("a network error is retried")
    func networkError() async throws {
        let fake = FakeHTTPClient([.failure(URLError(.networkConnectionLost)), ok])
        let client = RetryingHTTPClient(wrapping: fake, sleep: { _ in })

        #expect(try await client.get(url).statusCode == 200)
        #expect(await fake.requested.count == 2)
    }

    @Test("4xx is not retried: the request itself is wrong")
    func clientError() async throws {
        let fake = FakeHTTPClient([.response(Data(), 400), ok])
        let client = RetryingHTTPClient(wrapping: fake, sleep: { _ in })

        #expect(try await client.get(url).statusCode == 400)
        #expect(await fake.requested.count == 1)
    }

    @Test("gives up after two retries")
    func givesUp() async throws {
        let fake = FakeHTTPClient(Array(repeating: .response(Data(), 500), count: 3))
        let client = RetryingHTTPClient(wrapping: fake, sleep: { _ in })

        #expect(try await client.get(url).statusCode == 500)
        #expect(await fake.requested.count == 3)
    }

    @Test("a cancelled request is not retried")
    func cancelled() async {
        let fake = FakeHTTPClient([.failure(URLError(.cancelled)), ok])
        let client = RetryingHTTPClient(wrapping: fake, sleep: { _ in })

        await #expect(throws: URLError.self) { try await client.get(url) }
        #expect(await fake.requested.count == 1)
    }
}

@Suite("OpenMeteoAPI")
struct OpenMeteoAPITests {
    @Test("the forecast request asks for exactly the fields in the API contract")
    func forecastQuery() async throws {
        let fake = FakeHTTPClient([.response(try Samples.data("forecast_istanbul.json"), 200)])

        _ = try await OpenMeteoAPI(client: fake).forecast(latitude: 41.01, longitude: 28.97)

        let url = try #require(await fake.requested.first)
        #expect(url.path == "/v1/forecast")
        #expect(url.query("latitude") == "41.01")
        #expect(url.query("longitude") == "28.97")
        #expect(url.query("current") == OpenMeteoAPI.currentFields)
        #expect(url.query("hourly") == OpenMeteoAPI.hourlyFields)
        #expect(url.query("daily") == OpenMeteoAPI.dailyFields)
        #expect(url.query("timezone") == "auto")
        #expect(url.query("forecast_days") == "7")
        #expect(url.query("forecast_hours") == "24")
    }

    @Test("search sends the name and the language")
    func searchQuery() async throws {
        let fake = FakeHTTPClient([.response(try Samples.data("geocoding_istanbul_tr.json"), 200)])

        let result = try await OpenMeteoAPI(client: fake).searchCities(name: "İstanbul", languageCode: "tr")

        let url = try #require(await fake.requested.first)
        #expect(url.query("name") == "İstanbul")
        #expect(url.query("language") == "tr")
        #expect(result.results?.first?.name == "İstanbul")
    }

    @Test("a non-2xx answer becomes an HTTP status error")
    func badStatus() async throws {
        let fake = FakeHTTPClient([.response(try Samples.data("forecast_error.json"), 400)])

        await #expect(throws: HTTPStatusError(code: 400)) {
            try await OpenMeteoAPI(client: fake).forecast(latitude: 41, longitude: 28)
        }
    }
}
