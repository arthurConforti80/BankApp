//
//  DirectDebitDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Body de POST .../direct-debit, tirado do resource-docs da própria
/// sandbox. Comportamento em runtime ainda NÃO testado ponta a ponta.
struct CreateDirectDebitRequestDTO: Encodable {
    let counterparty_id: String
    let date_signed: String
    let date_starts: String
    let date_expires: String?
}

struct DirectDebitResponseDTO: Decodable {
    let direct_debit_id: String?
}
