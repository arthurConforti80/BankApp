//
//  Account.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Domain entity, what the ViewModel and the View actually consume.
/// Never the same type as the DTO returned by the API: the DTO -> Entity
/// mapping happens in the UseCase, so an OBP response format doesn't leak into the UI.
///
/// `balance` and `currency` are optional because the OBP account listing
/// (GET /my/accounts) doesn't include a balance. That requires an additional
/// call per account (see AccountsUseCase). For now they stay nil; fetching
/// the balance is the natural next step for this module.
public struct Account: Identifiable, Equatable {
    public let id: String
    public let bankId: String
    public let label: String
    public let accountType: String
    public let iban: String?
    public let balance: Decimal?
    public let currency: String?

    public init(
        id: String,
        bankId: String,
        label: String,
        accountType: String,
        iban: String?,
        balance: Decimal? = nil,
        currency: String? = nil
    ) {
        self.id = id
        self.bankId = bankId
        self.label = label
        self.accountType = accountType
        self.iban = iban
        self.balance = balance
        self.currency = currency
    }
}
