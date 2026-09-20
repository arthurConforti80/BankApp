//
//  AccountsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Espelha (aproximadamente) o formato de resposta de
/// GET /obp/v4.0.0/my/accounts da sandbox OBP. Ver API Explorer
/// (https://apiexplorersandbox.openbankproject.com) para confirmar o
/// schema exato antes de usar contra a sandbox real — isto é uma
/// aproximação razoável para fins de demonstração da camada de mapeamento.
struct AccountsResponseDTO: Decodable {
    let accounts: [AccountDTO]
}

struct AccountDTO: Decodable {
    let id: String
    let bankId: String
    let label: String
    let balance: BalanceDTO

    enum CodingKeys: String, CodingKey {
        case id
        case bankId = "bank_id"
        case label
        case balance
    }
}

struct BalanceDTO: Decodable {
    let currency: String
    let amount: String
}
