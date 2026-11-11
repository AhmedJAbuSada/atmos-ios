import AtmosDomain

/// # AtmosData
///
/// Talks to the outside world (Open-Meteo, files, settings, location) and implements the
/// repository protocols declared in AtmosDomain (step 04).
public enum AtmosData {
    public static let layer = "data"

    /// Proves the dependency on the domain is allowed: data may use domain types.
    public static let reportsErrorsAs: DomainError.Type = DomainError.self
}
