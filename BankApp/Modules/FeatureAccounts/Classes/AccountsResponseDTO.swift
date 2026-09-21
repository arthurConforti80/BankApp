//
//  AccountsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Espelha o formato de resposta de GET /obp/v4.0.0/my/accounts da sandbox
/// OBP, confirmado contra chamada real (não traz saldo — a listagem só
/// retorna metadados da conta; saldo exige uma chamada por conta separada,
/// ver comentário em AccountsUseCase.fetchAccounts()).
struct AccountsResponseDTO: Decodable {
    let accounts: [AccountDTO]
}

struct AccountDTO: Decodable {
    let id: String
    let label: String?
    let bankId: String
    let accountType: String
    let accountRoutings: [AccountRoutingDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case label
        case bankId = "bank_id"
        case accountType = "account_type"
        case accountRoutings = "account_routings"
    }
}

struct AccountRoutingDTO: Decodable {
    let scheme: String
    let address: String
}
