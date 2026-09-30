//
//  FxRate.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Domain entity, conversion rate between two currencies.
public struct FxRate: Identifiable, Equatable {
    public var id: String { "\(fromCurrency)\(toCurrency)" }
    public let fromCurrency: String
    public let toCurrency: String
    public let conversionValue: Decimal

    public init(fromCurrency: String, toCurrency: String, conversionValue: Decimal) {
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.conversionValue = conversionValue
    }
}
