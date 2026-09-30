//
//  DirectDebitDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body for POST .../direct-debit (the sandbox's own resource docs).
/// `customer_id` and `user_id` are required, the same issue confirmed in
/// Standing Order and Counterparty (400 "No usable value" when missing).
/// `date_expires` also needs to always be present.
struct CreateDirectDebitRequestDTO: Encodable {
    let customer_id: String
    let user_id: String
    let counterparty_id: String
    let date_signed: String
    let date_starts: String
    let date_expires: String
}

struct DirectDebitResponseDTO: Decodable {
    let direct_debit_id: String?
}
