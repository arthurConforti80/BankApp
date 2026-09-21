//
//  CreditCard.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation

/// Entity de domínio. Note que `maskedNumber` já vem mascarado — a Entity
/// nunca deve carregar o número completo do cartão até a camada de
/// apresentação; o mascaramento acontece no mapeamento DTO -> Entity
/// (ver FeatureCards.CardsUseCase), nunca na View.
public struct CreditCard: Identifiable, Equatable {
    public let id: String
    public let bankId: String
    public let accountId: String
    public let nameOnCard: String
    public let maskedNumber: String

    public init(id: String, bankId: String, accountId: String, nameOnCard: String, maskedNumber: String) {
        self.id = id
        self.bankId = bankId
        self.accountId = accountId
        self.nameOnCard = nameOnCard
        self.maskedNumber = maskedNumber
    }
}
