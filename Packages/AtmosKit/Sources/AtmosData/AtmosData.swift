import AtmosDomain

/// # AtmosData
///
/// Talks to the outside world (Open-Meteo, files, settings, location) and implements the
/// repository protocols declared in ``AtmosDomain`` (step 04).
public enum AtmosData {
    public static let layer = "data"

    /// The layer this one depends on. Referencing it proves the dependency is allowed.
    public static let dependsOn = AtmosDomain.layer
}
