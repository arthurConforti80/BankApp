//
//  StandingOrderDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body de POST .../standing-order (resource-docs da própria sandbox).
/// `customer_id` e `user_id` são obrigatórios e a sandbox retorna 400
/// "No usable value" se omitidos — confirmado em 30/09/2026 junto com o
/// mesmo problema no Counterparty. `date_expires` também precisa estar
/// sempre presente no JSON (mesmo bug do campo omitido quando nil), por
/// isso não é mais opcional aqui: sem data final, o UseCase manda uma
/// data bem no futuro.
struct CreateStandingOrderRequestDTO: Encodable {
    struct Amount: Encodable {
        let currency: String
        let amount: String
    }

    struct When: Encodable {
        let frequency: String
        let detail: String
    }

    let customer_id: String
    let user_id: String
    let counterparty_id: String
    let amount: Amount
    let when: When
    let date_signed: String
    let date_starts: String
    let date_expires: String
}

struct StandingOrderResponseDTO: Decodable {
    let standing_order_id: String?
}
