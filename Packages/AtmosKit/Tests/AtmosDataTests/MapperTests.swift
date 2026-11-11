@testable import AtmosData
import AtmosDomain
import AtmosTesting
import Foundation
import Testing

@Suite("ForecastMapper")
struct ForecastMapperTests {
    let requested = TestData.istanbul
    let fetchedAt = TestData.now

    func recorded() throws -> Forecast {
        let dto = try JSONDecoder().decode(ForecastDTO.self, from: Samples.data("forecast_istanbul.json"))
        return try ForecastMapper.map(dto, requested: requested, fetchedAt: fetchedAt)
    }

    func istanbulTime(_ text: String) -> Date? {
        LocalTimeParser(timeZone: TimeZone(identifier: "Europe/Istanbul") ?? .gmt).dateTime(text)
    }

    @Test("maps the current conditions of the recorded Istanbul response")
    func current() throws {
        let current = try recorded().current
        #expect(current.time == istanbulTime("2026-11-11T10:15"))
        #expect(current.temperature == Temperature(celsius: 14.9))
        #expect(current.feelsLike == Temperature(celsius: 11.2))
        #expect(current.humidityPercent == 69)
        #expect(current.windSpeed == WindSpeed(kilometersPerHour: 24.8))
        #expect(current.condition == .overcast)
        #expect(current.isDay)
    }

    @Test("local times are read in the place's time zone, not the phone's")
    func timeZone() throws {
        // 10:15 in Istanbul (UTC+3) is 07:15 UTC.
        let utc = try recorded().current.time
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        #expect(calendar.component(.hour, from: utc) == 7)
        #expect(try recorded().timeZone.identifier == "Europe/Istanbul")
    }

    @Test("zips the parallel hourly arrays into 24 hours")
    func hourly() throws {
        let hourly = try recorded().hourly
        #expect(hourly.count == 24)
        #expect(hourly.first?.time == istanbulTime("2026-11-11T10:00"))
        #expect(hourly.first?.temperature == Temperature(celsius: 14.8))
        #expect(hourly.first?.condition == .partlyCloudy)
        #expect(hourly.first?.precipitationChancePercent == 0)
    }

    @Test("maps 7 days with sunrise and sunset")
    func daily() throws {
        let daily = try recorded().daily
        #expect(daily.count == 7)
        #expect(daily.first?.minTemperature == Temperature(celsius: 11.4))
        #expect(daily.first?.maxTemperature == Temperature(celsius: 16.9))
        #expect(daily.first?.sunrise == istanbulTime("2026-11-11T07:46"))
        #expect(daily.first?.sunset == istanbulTime("2026-11-11T17:49"))
    }

    @Test("keeps the requested coordinates, not the snapped ones from the response")
    func requestedCoordinates() throws {
        #expect(try recorded().coordinates == requested) // response says 41.02444, 28.940546
    }

    @Test("given no current conditions, then the response is invalid")
    func missingCurrent() {
        let dto = ForecastDTO(
            latitude: nil, longitude: nil, timezone: nil, utcOffsetSeconds: nil, current: nil, hourly: nil, daily: nil
        )
        #expect(throws: InvalidResponseError.self) {
            try ForecastMapper.map(dto, requested: requested, fetchedAt: fetchedAt)
        }
    }

    @Test("given arrays of different lengths, then maps only complete hours instead of crashing")
    func uneven() throws {
        // Three times, but only two temperatures (one of them null) and one weather code.
        let json = """
        {"timezone": "UTC",
         "current": {"time": "2026-11-11T10:15", "temperature_2m": 15,
                     "relative_humidity_2m": 60, "wind_speed_10m": 10},
         "hourly": {"time": ["2026-11-11T10:00", "2026-11-11T11:00", "2026-11-11T12:00"],
                    "temperature_2m": [14.8, null], "weather_code": [2]}}
        """
        let dto = try JSONDecoder().decode(ForecastDTO.self, from: Data(json.utf8))
        let hourly = try ForecastMapper.map(dto, requested: requested, fetchedAt: fetchedAt).hourly
        #expect(hourly.count == 1)
        #expect(hourly.first?.precipitationChancePercent == nil)
    }

    @Test("an unknown time zone falls back to the UTC offset")
    func zoneFallback() {
        #expect(ForecastMapper.timeZone(named: "Mars/Olympus", offsetSeconds: 10_800).secondsFromGMT() == 10_800)
        #expect(ForecastMapper.timeZone(named: nil, offsetSeconds: nil) == .gmt)
    }
}

@Suite("CityMapper")
struct CityMapperTests {
    func cities(_ sample: String) throws -> [City] {
        CityMapper.map(try JSONDecoder().decode(GeocodingDTO.self, from: Samples.data(sample)))
    }

    @Test("maps the recorded Turkish search with Turkish names")
    func turkish() throws {
        let istanbul = try #require(try cities("geocoding_istanbul_tr.json").first)
        #expect(istanbul.id == 745_044)
        #expect(istanbul.name == "İstanbul")
        #expect(istanbul.countryCode == "TR")
    }

    @Test("maps the recorded Arabic search with Arabic names")
    func arabic() throws {
        #expect(try cities("geocoding_istanbul_ar.json").first?.name == "اسطنبول")
    }

    @Test("the same city has the same id in every language")
    func stableID() throws {
        let ids = try ["en", "tr", "ar"].map { try cities("geocoding_istanbul_\($0).json").first?.id }
        #expect(Set(ids) == [745_044])
    }

    @Test("a response with no results key is an empty list")
    func emptySearch() throws {
        // The real API omits "results" when nothing matches.
        #expect(try cities("geocoding_empty.json").isEmpty)
    }

    @Test("drops results that cannot be shown or saved")
    func invalid() {
        func city(id: Int? = 1, name: String? = "Ankara", latitude: Double? = 39.9) -> CityDTO {
            CityDTO(id: id, name: name, latitude: latitude, longitude: 32.8, countryCode: nil, country: " ", admin1: "")
        }
        #expect(CityMapper.map(city())?.name == "Ankara")
        #expect(CityMapper.map(city())?.country == nil) // a blank country becomes nil
        #expect(CityMapper.map(city(id: nil)) == nil)
        #expect(CityMapper.map(city(name: " ")) == nil)
        #expect(CityMapper.map(city(latitude: 999)) == nil)
    }
}
