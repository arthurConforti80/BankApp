//
//  CardsUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation
import Core

public protocol CardsUseCaseProtocol {
    func fetchCards() async throws -> [CreditCard]
    func fetchRecentTransactions(for card: CreditCard, limit: Int) async throws -> [Transaction]
}

public final class CardsUseCase: CardsUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let transactionsService: TransactionsServiceProtocol

    public init(apiClient: OBPAPIClient = .shared, transactionsService: TransactionsServiceProtocol = TransactionsService()) {
        self.apiClient = apiClient
        self.transactionsService = transactionsService
    }

    public func fetchCards() async throws -> [CreditCard] {
        // A documentação pública lista este endpoint sob /obp/v5.0.0/cards,
        // enquanto o resto do app usa v4.0.0 — sobrescrevemos a versão só
        // nesta chamada. Confirme no API Explorer se v4.0.0 também expõe o
        // mesmo caminho antes de depender disso fora de um protótipo.
        let response: CardsResponseDTO = try await apiClient.get(path: "/cards", apiVersionOverride: "v5.0.0")
        return response.cards.compactMap { dto in
            guard let cardId = dto.cardId, let bankId = dto.bankId, let accountId = dto.accountId else {
                return nil
            }
            return CreditCard(
                id: cardId,
                bankId: bankId,
                accountId: accountId,
                nameOnCard: dto.nameOnCard ?? "",
                maskedNumber: Self.mask(dto.bankCardNumber)
            )
        }
    }

    /// Cartão não tem extrato próprio na OBP — extrato é sempre vinculado
    /// a uma conta. Por isso buscamos as transações da conta associada ao
    /// cartão (card.accountId), reaproveitando o mesmo Core.TransactionsService
    /// que FeatureAccounts usa.
    public func fetchRecentTransactions(for card: CreditCard, limit: Int) async throws -> [Transaction] {
        try await transactionsService.fetchRecentTransactions(bankId: card.bankId, accountId: card.accountId, limit: limit)
    }

    private static func mask(_ number: String?) -> String {
        guard let number, number.count >= 4 else { return "•••• ••••" }
        return "•••• \(number.suffix(4))"
    }
}
