import SwiftUI

/// A full-screen message with optional actions: used for errors and empty states (F-10).
struct MessageView: View {
    var title: LocalizedStringKey?
    let message: LocalizedStringKey
    var actionTitle: LocalizedStringKey?
    var action: (@MainActor () -> Void)?
    var secondaryTitle: LocalizedStringKey?
    var secondaryAction: (@MainActor () -> Void)?

    var body: some View {
        VStack(spacing: AtmosTheme.Spacing.medium) {
            if let title {
                Text(title, bundle: .module)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
            }
            Text(message, bundle: .module)
                .font(.body)
                .foregroundStyle(.secondary)
            if let actionTitle, let action {
                Button { action() } label: { Text(actionTitle, bundle: .module) }
                    .buttonStyle(.borderedProminent)
            }
            if let secondaryTitle, let secondaryAction {
                Button { secondaryAction() } label: { Text(secondaryTitle, bundle: .module) }
                    .buttonStyle(.bordered)
            }
        }
        .multilineTextAlignment(.center)
        .padding(AtmosTheme.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// The "Updated 2 hours ago" strip over outdated data (F-08).
struct InfoBanner: View {
    let text: Text

    var body: some View {
        Label { text } icon: { Image(systemName: "info.circle") }
            .font(.subheadline)
            .padding(AtmosTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.yellow.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
    }
}

/// A grey block in the shape of the content to come (US-09: a skeleton, not a blank screen).
/// `redacted` would also work; explicit blocks keep the layout stable for every locale.
struct SkeletonBlock: View {
    var width: CGFloat?
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.secondary.opacity(0.2))
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .accessibilityHidden(true)
    }
}
