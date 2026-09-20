//
//  Account.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Entity de domínio — o que o ViewModel e a View efetivamente consomem.
/// Nunca é o mesmo tipo que o DTO retornado pela API: o mapeamento DTO -> Entity
/// acontece no UseCase, para que um formato de resposta da OBP não vaze pra UI.
public struct Account: Identifiable, Equatable {
    public let id: String
    public let bankId: String
    public let label: String
    public let balance: Decimal
    public let currency: String

    public init(id: String, bankId: String, label: String, balance: Decimal, currency: String) {
        self.id = id
        self.bankId = bankId
        self.label = label
        self.balance = balance
        self.currency = currency
    }
}
