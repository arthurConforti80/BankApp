//
//  DirectDebitDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body de POST .../direct-debit (resource-docs da própria sandbox).
/// `customer_id` e `user_id` são obrigatórios — mesmo problema confirmado
/// em Standing Order e Counterparty (400 "No usable value" quando
/// ausentes). `date_expires` também precisa estar sempre presente.
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
