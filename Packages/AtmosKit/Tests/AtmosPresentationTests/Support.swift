import Foundation

/// Waits until `condition` is true, checking every 10 ms, for at most 2 seconds. View models
/// update their state from background tasks; tests wait for the outcome instead of sleeping
/// for a fixed time.
@MainActor
func eventually(_ condition: @MainActor () -> Bool) async -> Bool {
    for _ in 0..<200 {
        if condition() { return true }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// The same, for a condition that must `await` (for example, reading a fake repository).
@MainActor
func eventuallyAsync(_ condition: @MainActor () async -> Bool) async -> Bool {
    for _ in 0..<200 {
        if await condition() { return true }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return await condition()
}
