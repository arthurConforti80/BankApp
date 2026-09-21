//
//  CardsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation

/// Schema aproximado de GET /cards. A documentação pública lista campos
/// bem mais extensos (replacement, pin_reset, networks, allows...) — só
/// declaramos aqui o que realmente usamos, e tudo opcional, seguindo a
/// mesma lição aprendida com AccountDTO: confirmar contra o API Explorer
/// antes de depender disso em produção.
struct CardsResponseDTO: Decodable {
    let cards: [CardDTO]
}

struct CardDTO: Decodable {
    let cardId: String?
    let bankId: String?
    let accountId: String?
    let nameOnCard: String?
    let bankCardNumber: String?

    enum CodingKeys: String, CodingKey {
        case cardId = "card_id"
        case bankId = "bank_id"
        case accountId = "account_id"
        case nameOnCard = "name_on_card"
        case bankCardNumber = "bank_card_number"
    }
}
