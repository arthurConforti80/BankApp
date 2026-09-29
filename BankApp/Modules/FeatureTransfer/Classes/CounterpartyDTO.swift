//
//  CounterpartyDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body de POST .../counterparties. `currency` é obrigatório — confirmado
/// em 29/09/2026 contra a sandbox real (erro 400 "No usable value for
/// currency" ao omiti-lo). Os demais campos seguem a doc pública da OBP
/// e ainda não foram validados individualmente contra uma resposta 2xx.
struct CreateCounterpartyRequestDTO: Encodable {
    let name: String
    let description: String?
    let currency: String
    let other_account_routing_scheme: String
    let other_account_routing_address: String
    let other_bank_routing_scheme: String
    let other_bank_routing_address: String
    let is_beneficiary: Bool
}

struct CounterpartyResponseDTO: Decodable {
    let counterparty_id: String?
    let name: String?
}
