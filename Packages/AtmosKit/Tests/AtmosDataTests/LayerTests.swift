import AtmosData
import Testing

@Test("the data layer depends on the domain layer")
func dataDependsOnDomain() {
    #expect(AtmosData.dependsOn == "domain")
}
