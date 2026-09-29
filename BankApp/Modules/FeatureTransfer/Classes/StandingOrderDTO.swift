//
//  StandingOrderDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body de POST .../standing-order. Schema tirado direto do
/// resource-docs da própria sandbox (não é um schema genérico da doc
/// pública) — mas o comportamento em runtime (aceitar counterparty_id
/// de um beneficiário recém-criado, o formato exato de `when.detail`)
/// ainda NÃO foi testado ponta a ponta.
struct CreateStandingOrderRequestDTO: Encodable {
    struct Amount: Encodable {
        let currency: String
        let amount: String
    }

    struct When: Encodable {
        let frequency: String
        let detail: String
    }

    let counterparty_id: String
    let amount: Amount
    let when: When
    let date_signed: String
    let date_starts: String
    let date_expires: String?
}

struct StandingOrderResponseDTO: Decodable {
    let standing_order_id: String?
}
