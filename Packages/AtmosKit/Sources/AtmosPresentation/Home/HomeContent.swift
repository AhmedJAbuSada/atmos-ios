import AtmosDomain
import SwiftUI

/// The Home screen (US-01, US-02, US-03, US-07). Stateless: it shows `state` and reports
/// `actions`. It never talks to a view model, a repository or the network.
public struct HomeContent: View {
    let state: HomeState
    let actions: HomeActions

    public init(state: HomeState, actions: HomeActions) {
        self.state = state
        self.actions = actions
    }

    public var body: some View {
        content
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button { actions.openCities() } label: {
                        Label { Text("home.openCities", bundle: .module) } icon: {
                            Image(systemName: "list.bullet")
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { actions.openSettings() } label: {
                        Label { Text("home.openSettings", bundle: .module) } icon: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
    }

    @ViewBuilder private var content: some View {
        switch state {
        case .loading:
            HomeSkeleton()
        case .needsLocation:
            MessageView(
                title: "home.noLocation.title",
                message: "home.noLocation.message",
                actionTitle: "home.allowLocation",
                action: { actions.requestLocation() },
                secondaryTitle: "home.searchCity",
                secondaryAction: { actions.openCities() }
            )
        case let .failed(error):
            MessageView(message: error.message, actionTitle: "action.retry", action: { actions.retry() })
        case let .content(content):
            ForecastView(content: content)
                .refreshable { await actions.refresh() }
        }
    }

    private var title: Text {
        guard case let .content(content) = state else { return Text(verbatim: "") }
        if let name = content.placeName { return Text(verbatim: name) }
        return Text("home.currentLocation", bundle: .module)
    }
}

private struct ForecastView: View {
    let content: HomeContentState
    @Environment(\.locale) private var locale

    var body: some View {
        let format = WeatherFormatter(locale: locale, timeZone: content.forecast.timeZone)
        ScrollView {
            VStack(alignment: .leading, spacing: AtmosTheme.Spacing.large) {
                if let age = content.outdatedBy { InfoBanner(text: updatedAgo(age)) }
                CurrentConditionsView(current: content.forecast.current, settings: content.settings, format: format)
                SectionTitle("home.next24Hours")
                    .accessibilityIdentifier("home.hourly")
                HourlyRow(hours: content.forecast.hourly, unit: content.settings.temperatureUnit, format: format)
                SectionTitle("home.next7Days")
                VStack(spacing: 0) {
                    ForEach(Array(content.forecast.daily.enumerated()), id: \.element.id) { index, day in
                        DayRow(day: day, isToday: index == 0, unit: content.settings.temperatureUnit, format: format)
                        Divider()
                    }
                }
                Text("home.attribution", bundle: .module)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(AtmosTheme.Spacing.medium)
        }
    }

    /// "Updated 2 hours ago", with the right plural form in every language.
    private func updatedAgo(_ seconds: TimeInterval) -> Text {
        let minutes = Int(seconds / 60)
        if minutes >= 24 * 60 { return Text("home.updated.days \(minutes / (24 * 60))", bundle: .module) }
        if minutes >= 60 { return Text("home.updated.hours \(minutes / 60)", bundle: .module) }
        return Text("home.updated.minutes \(minutes)", bundle: .module)
    }
}

private struct SectionTitle: View {
    let key: LocalizedStringKey

    init(_ key: LocalizedStringKey) {
        self.key = key
    }

    var body: some View {
        Text(key, bundle: .module)
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct CurrentConditionsView: View {
    let current: CurrentWeather
    let settings: UserSettings
    let format: WeatherFormatter

    var body: some View {
        VStack(spacing: AtmosTheme.Spacing.extraSmall) {
            Image(systemName: current.condition.symbolName(isDay: current.isDay))
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 72))
                .accessibilityHidden(true) // the condition is written right below
            Text(verbatim: format.temperature(current.temperature, unit: settings.temperatureUnit))
                .font(.system(size: 88, weight: .thin))
            Text(current.condition.label, bundle: .module)
                .font(.title2.weight(.semibold))
            let feelsLike = format.temperature(current.feelsLike, unit: settings.temperatureUnit)
            let wind = format.windSpeed(current.windSpeed, unit: settings.windSpeedUnit)
            Text("home.feelsLike \(feelsLike)", bundle: .module)
            Text("home.humidity \(format.percentage(current.humidityPercent))", bundle: .module)
                + Text(verbatim: " · ")
                + Text("home.wind \(wind)", bundle: .module)
        }
        .foregroundStyle(.primary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

/// A horizontal list. In Arabic it starts on the right and scrolls left, automatically.
private struct HourlyRow: View {
    let hours: [HourlyForecast]
    let unit: TemperatureUnit
    let format: WeatherFormatter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: AtmosTheme.Spacing.small) {
                ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
                    HourCell(hour: hour, isNow: index == 0, unit: unit, format: format)
                }
            }
        }
    }
}

private struct HourCell: View {
    let hour: HourlyForecast
    let isNow: Bool
    let unit: TemperatureUnit
    let format: WeatherFormatter

    var body: some View {
        let chance = hour.precipitationChancePercent.flatMap { $0 > 0 ? format.percentage($0) : nil }
        VStack(spacing: AtmosTheme.Spacing.extraSmall) {
            time.font(.caption)
            Image(systemName: hour.condition.symbolName())
                .symbolRenderingMode(.multicolor)
                .font(.title2)
            Text(verbatim: format.temperature(hour.temperature, unit: unit))
                .font(.headline.monospacedDigit())
            // Hidden at 0% to reduce noise (US-02); the space is kept so cells line up.
            Text(verbatim: chance ?? " ")
                .font(.caption2)
                .foregroundStyle(AtmosTheme.accent)
        }
        .padding(AtmosTheme.Spacing.small)
        .frame(minWidth: 64)
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        // One clear sentence for VoiceOver instead of four fragments.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(chance))
    }

    private var time: Text {
        isNow ? Text("home.now", bundle: .module) : Text(verbatim: format.hour(hour.time))
    }

    private func accessibilityText(_ chance: String?) -> Text {
        var text = time + Text(verbatim: ", ") + Text(hour.condition.label, bundle: .module)
            + Text(verbatim: ", " + format.temperature(hour.temperature, unit: unit))
        if let chance {
            text = text + Text(verbatim: ", ") + Text("home.precipitationChance \(chance)", bundle: .module)
        }
        return text
    }
}

/// One day. Tapping it shows sunrise and sunset (US-03); whether it is open is UI state, so it
/// lives here in `@State`, not in a view model.
private struct DayRow: View {
    let day: DailyForecast
    let isToday: Bool
    let unit: TemperatureUnit
    let format: WeatherFormatter
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation { isExpanded.toggle() }
        } label: {
            VStack(alignment: .leading, spacing: AtmosTheme.Spacing.extraSmall) {
                HStack(spacing: AtmosTheme.Spacing.medium) {
                    name.frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: day.condition.symbolName())
                        .symbolRenderingMode(.multicolor)
                        .accessibilityHidden(true)
                    Text(verbatim: format.temperature(day.minTemperature, unit: unit))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Text(verbatim: format.temperature(day.maxTemperature, unit: unit))
                        .monospacedDigit()
                }
                if isExpanded, let sunrise = day.sunrise, let sunset = day.sunset {
                    Text("home.sunriseSunset \(format.hour(sunrise)) \(format.hour(sunset))", bundle: .module)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: AtmosTheme.Spacing.tapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityValue(Text(day.condition.label, bundle: .module))
    }

    private var name: Text {
        isToday ? Text("home.today", bundle: .module) : Text(verbatim: format.dayName(day.date))
    }
}

/// The same layout as the content, in grey (US-09).
private struct HomeSkeleton: View {
    var body: some View {
        VStack(spacing: AtmosTheme.Spacing.medium) {
            SkeletonBlock(width: 96, height: 96)
            SkeletonBlock(width: 160, height: 88)
            SkeletonBlock(width: 200, height: 24)
            HStack(spacing: AtmosTheme.Spacing.small) {
                ForEach(0..<5, id: \.self) { _ in SkeletonBlock(width: 64, height: 112) }
            }
            ForEach(0..<4, id: \.self) { _ in SkeletonBlock(height: 44) }
            Spacer()
        }
        .padding(AtmosTheme.Spacing.medium)
    }
}

#Preview("Content") {
    NavigationStack { HomeContent(state: .content(PreviewData.content), actions: .none) }
}

#Preview("Arabic, dark") {
    NavigationStack { HomeContent(state: .content(PreviewData.content), actions: .none) }
        .environment(\.locale, Locale(identifier: "ar"))
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("Turkish, outdated, largest text") {
    NavigationStack { HomeContent(state: .content(PreviewData.outdated), actions: .none) }
        .environment(\.locale, Locale(identifier: "tr"))
        .dynamicTypeSize(.accessibility3)
}

#Preview("Loading") { NavigationStack { HomeContent(state: .loading, actions: .none) } }

#Preview("Needs location") { NavigationStack { HomeContent(state: .needsLocation, actions: .none) } }

#Preview("Offline") { NavigationStack { HomeContent(state: .failed(.noConnection), actions: .none) } }
