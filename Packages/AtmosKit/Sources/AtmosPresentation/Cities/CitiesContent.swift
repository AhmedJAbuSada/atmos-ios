import AtmosDomain
import SwiftUI

/// The Cities screen (US-04, US-05). Saved cities are removed with the standard swipe; iOS
/// also offers the same action to VoiceOver users, so no gesture-only feature is created.
public struct CitiesContent: View {
    let state: CitiesState
    let actions: CitiesActions
    @Environment(\.locale) private var locale

    public init(state: CitiesState, actions: CitiesActions) {
        self.state = state
        self.actions = actions
    }

    public var body: some View {
        List { sections }
            .navigationTitle(Text("cities.title", bundle: .module))
            .searchable(
                text: Binding(get: { state.query }, set: { actions.queryChanged($0) }),
                prompt: Text("cities.searchPrompt", bundle: .module)
            )
            .overlay { overlay }
            .safeAreaInset(edge: .bottom) { noticeBanner }
            .animation(.default, value: state.notice)
    }

    /// iOS has no built-in snackbar; this small banner plays that role (US-05).
    @ViewBuilder private var noticeBanner: some View {
        if let notice = state.notice {
            HStack {
                switch notice {
                case let .removed(city):
                    Text("cities.removed \(city.name)", bundle: .module)
                    Spacer()
                    Button { actions.undo() } label: { Text("cities.undo", bundle: .module).bold() }
                case let .alreadySaved(city):
                    Text("cities.alreadySaved \(city.name)", bundle: .module)
                    Spacer()
                }
            }
            .padding(AtmosTheme.Spacing.medium)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(AtmosTheme.Spacing.medium)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ViewBuilder private var sections: some View {
        switch state.search {
        case .idle:
            ForEach(state.places) { item in placeRow(item) }
        case let .results(cities):
            ForEach(cities) { city in resultRow(city) }
        case .searching, .noResults, .failed:
            EmptyView()
        }
    }

    @ViewBuilder private var overlay: some View {
        switch state.search {
        case .searching:
            ProgressView()
        case .noResults:
            MessageView(message: "cities.noResults")
        case let .failed(error):
            MessageView(message: error.message, actionTitle: "action.retry", action: { actions.retrySearch() })
        case .idle where !hasSavedCities:
            MessageView(message: "cities.emptySaved")
                .frame(maxHeight: .infinity, alignment: .bottom)
        default:
            EmptyView()
        }
    }

    private var hasSavedCities: Bool {
        state.places.contains { item in
            if case .saved = item.place { return true }
            return false
        }
    }

    private func resultRow(_ city: City) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(verbatim: city.name)
                Text(verbatim: [city.region, city.country].compactMap { $0 }.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { actions.add(city) } label: {
                Label { Text("cities.add \(city.name)", bundle: .module) } icon: {
                    Image(systemName: "plus.circle.fill")
                }
                .labelStyle(.iconOnly)
                .font(.title2)
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("cities.add.\(city.id)")
        }
        .frame(minHeight: AtmosTheme.Spacing.tapTarget)
    }

    @ViewBuilder private func placeRow(_ item: PlaceItem) -> some View {
        let row = Button { actions.select(item.place) } label: {
            HStack {
                switch item.place {
                case .currentLocation:
                    Label { Text("home.currentLocation", bundle: .module) } icon: { Image(systemName: "location.fill") }
                case let .saved(city):
                    Text(verbatim: city.name)
                }
                Spacer()
                if let temperature = item.temperature {
                    Text(verbatim: WeatherFormatter(locale: locale, timeZone: .current)
                        .temperature(temperature, unit: state.temperatureUnit))
                }
                if let condition = item.condition {
                    ConditionIcon(condition: condition)
                        .accessibilityLabel(Text(condition.label, bundle: .module))
                }
            }
            .frame(minHeight: AtmosTheme.Spacing.tapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("cities.place.\(item.id)")

        if case let .saved(city) = item.place {
            row.swipeActions {
                Button(role: .destructive) { actions.remove(city) } label: {
                    Label { Text("cities.remove \(city.name)", bundle: .module) } icon: { Image(systemName: "trash") }
                }
            }
        } else {
            row // the current location is always first and cannot be removed (US-05)
        }
    }
}

#Preview("Saved places") {
    NavigationStack { CitiesContent(state: PreviewData.cities, actions: .none) }
}

#Preview("Search results, Turkish") {
    NavigationStack {
        CitiesContent(state: CitiesState(query: "ista", search: .results([PreviewData.istanbul])), actions: .none)
    }
    .environment(\.locale, Locale(identifier: "tr"))
}

#Preview("No results, Arabic") {
    NavigationStack { CitiesContent(state: CitiesState(query: "zzqqxx", search: .noResults), actions: .none) }
        .environment(\.locale, Locale(identifier: "ar"))
        .environment(\.layoutDirection, .rightToLeft)
}
