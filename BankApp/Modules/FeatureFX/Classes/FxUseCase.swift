//
//  FxUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Core

public protocol FxUseCaseProtocol {
    func fetchRates() async throws -> [FxRate]
}

/// Fetches exchange rates for a fixed set of currency pairs. Each pair is an
/// independent call (GET /banks/{bank}/fx/{from}/{to}, v2.2.0, a different
/// version from the rest of the app, confirmed in the resource docs). The
/// bank_id used is the same one from the Products showcase ("inv.01.uk.uk"),
/// which is the bank with registered data in this multi-bank sandbox. It
/// hasn't been confirmed whether every sandbox has rates registered for
/// that specific bank_id, so a pair with no rate is treated as a normal
/// absence, not an error (the same stance already used in Products).
public final class FxUseCase: FxUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let bankId: String
    private let pairs: [(from: String, to: String)]

    public init(
        apiClient: OBPAPIClient = .shared,
        bankId: String = "inv.01.uk.uk",
        pairs: [(from: String, to: String)] = [("EUR", "USD"), ("EUR", "GBP"), ("EUR", "BRL")]
    ) {
        self.apiClient = apiClient
        self.bankId = bankId
        self.pairs = pairs
    }

    public func fetchRates() async throws -> [FxRate] {
        var rates: [FxRate] = []
        for pair in pairs {
            guard let dto: FxRateResponseDTO = try? await apiClient.get(
                path: "/banks/\(bankId)/fx/\(pair.from)/\(pair.to)",
                apiVersionOverride: "v2.2.0"
            ) else { continue }

            guard let from = dto.from_currency_code,
                  let to = dto.to_currency_code,
                  let value = dto.conversion_value else { continue }

            rates.append(FxRate(fromCurrency: from, toCurrency: to, conversionValue: Decimal(value)))
        }
        return rates
    }
}
