/// # AtmosDomain
///
/// The business core: entities, repository protocols and use cases (step 03).
///
/// **Rule:** this target imports Foundation only. No SwiftUI, UIKit, CoreLocation or
/// networking code, ever. That keeps the business rules testable on any platform, in
/// milliseconds (ADR-0001).
public enum AtmosDomain {
    /// The architecture layer this target implements, shown in diagnostics and tests.
    public static let layer = "domain"
}
