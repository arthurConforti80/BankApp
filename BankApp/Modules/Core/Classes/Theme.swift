//
//  Theme.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import SwiftUI

/// Palette and typography shared between BankApp's UI modules, mirroring
/// the design mockup (Login / Home / Detail). Lives in Core because
/// FeatureLogin, FeatureAccounts and FeatureCards need it, and no feature
/// module can depend on another.
///
/// The display fonts use the system's `.serif` design as a stand-in for the
/// mockup's Fraunces, and the `.default` design as a stand-in for Public
/// Sans, so there's no need to embed font files in the app.
public enum BankAppTheme {
    public enum Color {
        public static let ink = SwiftUI.Color(red: 0x16 / 255, green: 0x23 / 255, blue: 0x1F / 255)
        public static let cream = SwiftUI.Color(red: 0xF6 / 255, green: 0xF3 / 255, blue: 0xEA / 255)
        public static let emerald = SwiftUI.Color(red: 0x2F / 255, green: 0x5D / 255, blue: 0x50 / 255)
        public static let gold = SwiftUI.Color(red: 0xB9 / 255, green: 0x8A / 255, blue: 0x46 / 255)
        public static let mutedText = SwiftUI.Color(red: 0x55 / 255, green: 0x60 / 255, blue: 0x5A / 255)
        public static let hairline = SwiftUI.Color(red: 0xD9 / 255, green: 0xD2 / 255, blue: 0xBE / 255)
        public static let cardFill = SwiftUI.Color.white.opacity(0.6)
        public static let positive = emerald
        public static let negative = SwiftUI.Color(red: 0x9B / 255, green: 0x2E / 255, blue: 0x2E / 255)

        /// Tones used over the ink background (Home hero, Login panel): a
        /// lighter variation of ink for decorative elements (mini chart
        /// bars) and a light gray-green for secondary text that needs
        /// contrast over `ink`, since `mutedText` doesn't have enough
        /// contrast there.
        public static let barMuted = SwiftUI.Color(red: 0x3A / 255, green: 0x4A / 255, blue: 0x44 / 255)
        public static let mutedOnInk = SwiftUI.Color(red: 0xB8 / 255, green: 0xBD / 255, blue: 0xB6 / 255)

        /// Background track for the progress bars (spending summary).
        public static let trackFill = SwiftUI.Color(red: 0xEF / 255, green: 0xEA / 255, blue: 0xDA / 255)
    }

    public enum Typography {
        public static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
            .system(size: size, weight: weight, design: .serif)
        }

        public static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .default)
        }
    }

    /// Formats a signed value (+/-) for statement lines, in the pt-PT
    /// format (decimal comma) used in the mockup: "-42,30 EUR" / "+350,00 EUR".
    public static func formattedSignedAmount(_ amount: Decimal, currency: String) -> String {
        let formatted = decimalFormatter.string(from: NSDecimalNumber(decimal: abs(amount))) ?? "\(abs(amount))"
        let sign = amount < 0 ? "-" : (amount > 0 ? "+" : "")
        return "\(sign)\(formatted) \(currency)"
    }

    /// Formats a balance with no sign, same pt-PT format.
    public static func formattedBalance(_ amount: Decimal, currency: String) -> String {
        let formatted = decimalFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
        return "\(formatted) \(currency)"
    }

    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
