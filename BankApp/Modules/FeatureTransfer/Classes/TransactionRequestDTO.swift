//
//  TransactionRequestDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation

/// Body de POST .../transaction-request-types/SEPA/transaction-requests.
/// Schema ainda NÃO confirmado contra uma resposta real da sandbox — a
/// documentação pública da OBP descreve o tipo SEPA como aceitando um IBAN
/// de destino direto (sem precisar cadastrar um counterparty antes).
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

/// Resposta da criação/consulta de um transaction request. O nome exato do
/// campo de desafio (`challenge` vs `challenges`) NÃO está confirmado
/// contra a sandbox real — a wiki pública da OBP documenta o conceito
/// (status "INITIATED" + um challenge_id a responder) mas não o schema
/// exato campo a campo. Ver TransferUseCase para como isso é tratado.
struct TransactionRequestResponseDTO: Decodable {
    struct ChallengeDTO: Decodable {
        let id: String?
    }

    let id: String?
    let status: String?
    let challenge: ChallengeDTO?
}

/// Body de POST .../transaction-requests/{id}/challenge, respondendo o
/// desafio SANDBOX_TAN com o código recebido "fora de banda" (aqui,
/// simulado na UI).
struct ChallengeAnswerDTO: Encodable {
    let id: String
    let answer: String
}
