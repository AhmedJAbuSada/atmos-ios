/// Holds a current value and streams it to any number of observers: each new observer
/// receives the current value first, then every change. The Swift Concurrency equivalent of
/// Kotlin's `StateFlow`, used by repositories that publish lists and settings.
public actor ValueStream<Value: Sendable & Equatable> {
    public private(set) var value: Value
    private var continuations: [Int: AsyncStream<Value>.Continuation] = [:]
    private var nextID = 0

    public init(_ initial: Value) {
        value = initial
    }

    /// Replaces the value and notifies observers, unless nothing changed.
    public func send(_ newValue: Value) {
        guard newValue != value else { return }
        value = newValue
        for continuation in continuations.values { continuation.yield(newValue) }
    }

    /// A stream of the current value and every later change.
    public func values() -> AsyncStream<Value> {
        let (stream, continuation) = AsyncStream.makeStream(of: Value.self, bufferingPolicy: .bufferingNewest(1))
        let id = nextID
        nextID += 1
        continuations[id] = continuation
        continuation.yield(value)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeObserver(id) }
        }
        return stream
    }

    private func removeObserver(_ id: Int) {
        continuations[id] = nil
    }
}
