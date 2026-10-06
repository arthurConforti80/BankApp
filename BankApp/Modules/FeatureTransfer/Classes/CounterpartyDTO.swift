//
//  CounterpartyDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body for POST .../counterparties (PostCounterpartyJson400 schema from
/// OBP v4.0.0). The sandbox requires ALL fields below to be present in the
/// JSON (even if empty), confirmed on 29/09/2026 via successive 400
/// errors: "No usable value for currency" and then "No usable value
/// for other_account_secondary_routing_scheme". `bespoke` accepts an empty
/// array.
struct CreateCounterpartyRequestDTO: Encodable {
    let name: String
    let description: String?
    let currency: String
    let other_account_routing_scheme: String
    let other_account_routing_address: String
    let other_account_secondary_routing_scheme: String
    let other_account_secondary_routing_address: String
    let other_bank_routing_scheme: String
    let other_bank_routing_address: String
    let other_branch_routing_scheme: String
    let other_branch_routing_address: String
    let is_beneficiary: Bool
    let bespoke: [BespokeItemDTO]
}

struct BespokeItemDTO: Encodable {
    let key: String
    let value: String
}

struct CounterpartyResponseDTO: Decodable {
    let counterparty_id: String?
    let name: String?
}
