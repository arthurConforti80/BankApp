//
//  AccountsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Mirrors the response format of GET /obp/v4.0.0/my/accounts from the OBP
/// sandbox, confirmed against a real call (no balance included, the listing
/// only returns account metadata; balance requires a separate call per
/// account, see the comment in AccountsUseCase.fetchAccounts()).
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
