import AtmosDomain

/// Results without an id, a name or valid coordinates are dropped: they cannot be shown or
/// saved. A missing `results` key (no match) is an empty list.
enum CityMapper {
    static func map(_ dto: GeocodingDTO) -> [City] {
        (dto.results ?? []).compactMap(map)
    }

    static func map(_ dto: CityDTO) -> City? {
        guard let id = dto.id,
              let name = dto.name?.trimmingCharacters(in: .whitespaces), !name.isEmpty,
              let latitude = dto.latitude, let longitude = dto.longitude,
              let coordinates = Coordinates(latitude: latitude, longitude: longitude) else { return nil }
        return City(
            id: id,
            name: name,
            region: dto.admin1.nonBlank,
            country: dto.country.nonBlank,
            countryCode: dto.countryCode,
            coordinates: coordinates
        )
    }
}

private extension Optional where Wrapped == String {
    var nonBlank: String? {
        guard let value = self?.trimmingCharacters(in: .whitespaces), !value.isEmpty else { return nil }
        return value
    }
}
