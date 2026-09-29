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

/// Busca as taxas de câmbio pra um conjunto fixo de pares de moedas. Cada
/// par é uma chamada independente (GET /banks/{bank}/fx/{from}/{to}, v2.2.0
/// — versão diferente do resto do app, confirmada no resource-docs). O
/// bank_id usado é o mesmo da vitrine de Produtos ("inv.01.uk.uk"), que é
/// o banco com dados cadastrados nesta sandbox multi-banco — não foi
/// confirmado se toda sandbox tem taxas cadastradas pra esse bank_id
/// específico, então um par sem taxa é tratado como ausência normal, não
/// como erro (mesma postura já usada em Produtos).
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
