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
        // The public documentation lists this endpoint under /obp/v5.0.0/cards,
        // while the rest of the app uses v4.0.0, so we override the version
        // for just this call. Confirm in the API Explorer whether v4.0.0 also
        // exposes the same path before relying on this outside a prototype.
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

    /// A card doesn't have its own statement in OBP, a statement is always
    /// tied to an account. That's why we fetch the transactions for the
    /// account associated with the card (card.accountId), reusing the same
    /// Core.TransactionsService that FeatureAccounts uses.
    public func fetchRecentTransactions(for card: CreditCard, limit: Int) async throws -> [Transaction] {
        try await transactionsService.fetchRecentTransactions(bankId: card.bankId, accountId: card.accountId, limit: limit)
    }

    private static func mask(_ number: String?) -> String {
        guard let number, number.count >= 4 else { return "•••• ••••" }
        return "•••• \(number.suffix(4))"
    }
}
