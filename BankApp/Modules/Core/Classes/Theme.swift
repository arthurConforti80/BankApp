//
//  Theme.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import SwiftUI

/// Paleta e tipografia compartilhadas entre os módulos de UI do BankApp,
/// espelhando o mockup de design (Login / Home / Detalhe). Vive em Core
/// porque FeatureLogin, FeatureAccounts e FeatureCards precisam dela, e
/// nenhum feature module pode depender de outro.
///
/// As fontes de exibição usam o design `.serif` do sistema como stand-in
/// para a Fraunces do mockup, e o design `.default` como stand-in para a
/// Public Sans — assim não é preciso embutir arquivos de fonte no app.
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
    }

    public enum Typography {
        public static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
            .system(size: size, weight: weight, design: .serif)
        }

        public static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .default)
        }
    }

    /// Formata um valor com sinal (+/-) para linhas de extrato, no padrão
    /// pt-PT (vírgula decimal) usado no mockup: "-42,30 EUR" / "+350,00 EUR".
    public static func formattedSignedAmount(_ amount: Decimal, currency: String) -> String {
        let formatted = decimalFormatter.string(from: NSDecimalNumber(decimal: abs(amount))) ?? "\(abs(amount))"
        let sign = amount < 0 ? "-" : (amount > 0 ? "+" : "")
        return "\(sign)\(formatted) \(currency)"
    }

    /// Formata um saldo sem sinal, mesmo padrão pt-PT.
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
