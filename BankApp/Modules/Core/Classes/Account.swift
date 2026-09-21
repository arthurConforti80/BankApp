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
///
/// `balance` e `currency` são opcionais porque a listagem de contas da OBP
/// (GET /my/accounts) não traz saldo — isso exige uma chamada adicional por
/// conta (ver AccountsUseCase). Por ora ficam nil; buscar o saldo é o
/// próximo passo natural deste módulo.
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
