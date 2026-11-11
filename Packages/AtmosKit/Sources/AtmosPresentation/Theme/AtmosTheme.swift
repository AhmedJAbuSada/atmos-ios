import SwiftUI

/// The design system. Small on purpose: iOS already provides semantic colours (`.primary`,
/// `.secondary`, `.background`) that adapt to light, dark and high-contrast modes, and a type
/// scale that follows Dynamic Type. We add only what is ours: the brand accent and spacing.
public enum AtmosTheme {
    /// The brand blue, shared with the Android app. Used as the tint.
    public static let accent = Color(red: 0x1E / 255, green: 0x5A / 255, blue: 0xA8 / 255)

    /// Spacing on a 4 pt grid. Views use these, never a raw `16`.
    public enum Spacing {
        public static let extraSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        /// Minimum tap target (Apple HIG, NF-03).
        public static let tapTarget: CGFloat = 44
    }
}
