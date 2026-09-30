//
//  CustomerDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 30/09/2026.
//

import Foundation

/// Response of GET /banks/{BANK_ID}/customer (OBP v1.4.0). Schema taken
/// from the sandbox's own resource-docs; date_of_birth is decoded as a
/// best-effort ISO 8601 string (nil if the sandbox test customer has no
/// value set, which is common for these records).
struct CustomerResponseDTO: Decodable {
    let customer_id: String
    let customer_number: String?
    let legal_name: String?
    let email: String?
    let mobile_phone_number: String?
    let date_of_birth: String?
    let kyc_status: Bool?
    let employment_status: String?
    let relationship_status: String?
}

/// Body of POST .../web-hooks/account/notifications/on-create-transaction
/// (OBP v4.0.0). Confirmed against the sandbox's resource-docs on
/// 30/09/2026 — fires a server-side POST to `url` whenever a transaction
/// is created on any account at this bank.
struct CreateWebhookRequestDTO: Encodable {
    let url: String
    let http_method: String
    let http_protocol: String
}

struct CreateWebhookResponseDTO: Decodable {
    let webhook_id: String?
}
