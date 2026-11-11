import AtmosDomain
import Testing

/// Proves the test setup works; real domain tests arrive in step 03.
@Test("the domain target builds and is testable on any platform")
func domainLayer() {
    #expect(AtmosDomain.layer == "domain")
}
