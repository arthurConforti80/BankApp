//
//  CreditCard.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation

/// Domain entity. Note that `maskedNumber` already comes masked. The Entity
/// should never carry the full card number up to the presentation layer;
/// the masking happens in the DTO -> Entity mapping (see
/// FeatureCards.CardsUseCase), never in the View.
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
