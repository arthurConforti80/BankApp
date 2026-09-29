//
//  CounterpartyDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body de POST .../counterparties. Schema NÃO confirmado contra a
/// sandbox real — a documentação pública lista os campos abaixo como os
/// usados pela OBP pra registrar um beneficiário por IBAN, mas isso
/// precisa ser validado no API Explorer antes de qualquer uso além de
/// protótipo (mesmo cuidado já registrado pra Cartões e Transferência).
struct CreateCounterpartyRequestDTO: Encodable {
    let name: String
    let description: String?
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
