//
//  CardsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation

/// Approximate schema for GET /cards. The public documentation lists much
/// more extensive fields (replacement, pin_reset, networks, allows...); we
/// only declare here what we actually use, all optional, following the same
/// lesson learned with AccountDTO: confirm against the API Explorer before
/// depending on this in production.
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
