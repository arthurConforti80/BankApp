//
//  StandingOrderDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body for POST .../standing-order (the sandbox's own resource docs).
/// `customer_id` and `user_id` are required and the sandbox returns a 400
/// "No usable value" if they're omitted, confirmed on 30/09/2026 along
/// with the same issue in Counterparty. `date_expires` also needs to
/// always be present in the JSON (the same bug with the field omitted when
/// nil), which is why it's no longer optional here: with no end date, the
/// UseCase sends a date far in the future.
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
