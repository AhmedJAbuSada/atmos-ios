import AtmosData
import AtmosDomain
import Testing

@Test("the data layer depends on the domain layer")
func dataDependsOnDomain() {
    #expect(AtmosData.reportsErrorsAs == DomainError.self)
}
