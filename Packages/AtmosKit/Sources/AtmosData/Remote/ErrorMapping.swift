import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import AtmosDomain

extension DomainError {
    /// Translates any error from the network, the JSON decoder or the file system into a
    /// ``DomainError``. This is the **only** place in the app that knows about `URLError`
    /// (ADR-0006). Cancellation becomes `.cancelled`, never "offline" (ADR-0009).
    static func from(_ error: any Error) -> DomainError {
        switch error {
        case let error as DomainError:
            return error
        case is CancellationError:
            return .cancelled
        case let error as URLError:
            switch error.code {
            case .cancelled: return .cancelled
            case .timedOut: return .timeout
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost,
                 .cannotConnectToHost, .dnsLookupFailed, .dataNotAllowed, .internationalRoamingOff:
                return .noConnection
            default: return .unknown
            }
        case let error as HTTPStatusError:
            return error.code == 404 ? .notFound : .server(code: error.code)
        default:
            // DecodingError, InvalidResponseError, and anything unexpected.
            return .unknown
        }
    }
}
