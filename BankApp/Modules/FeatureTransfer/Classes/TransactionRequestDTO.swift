//
//  TransactionRequestDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation

/// Body for POST .../transaction-request-types/SEPA/transaction-requests.
/// Schema NOT yet confirmed against a real sandbox response. OBP's public
/// documentation describes the SEPA type as accepting a direct destination
/// IBAN (without needing to register a counterparty first).
struct TransactionRequestDTO: Encodable {
    struct Counterparty: Encodable {
        let iban: String
    }

    struct Value: Encodable {
        let currency: String
        let amount: String
    }

    let to: Counterparty
    let value: Value
    let description: String
}

/// Response from creating/querying a transaction request. The exact name of
/// the challenge field (`challenge` vs `challenges`) is NOT confirmed
/// against the real sandbox. OBP's public wiki documents the concept
/// (status "INITIATED" + a challenge_id to answer) but not the exact
/// field-by-field schema. See TransferUseCase for how this is handled.
struct TransactionRequestResponseDTO: Decodable {
    struct ChallengeDTO: Decodable {
        let id: String?
    }

    let id: String?
    let status: String?
    let challenge: ChallengeDTO?
}

/// Body for POST .../transaction-requests/{id}/challenge, answering the
/// SANDBOX_TAN challenge with the code received "out of band" (here,
/// simulated in the UI).
struct ChallengeAnswerDTO: Encodable {
    let id: String
    let answer: String
}
