//
//  CounterpartyDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body de POST .../counterparties (schema PostCounterpartyJson400 do
/// OBP v4.0.0). A sandbox exige TODOS os campos abaixo presentes no JSON
/// (mesmo que vazios) — confirmado em 29/09/2026 via erros 400
/// sucessivos: "No usable value for currency" e depois "No usable value
/// for other_account_secondary_routing_scheme". `bespoke` aceita array
/// vazio.
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
