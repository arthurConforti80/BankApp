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
/// de destino direto (sem precisar cadastrar um counterparty antes), mas
/// isso precisa ser validado no API Explorer antes de qualquer uso além de
/// protótipo. Ver também: a sandbox pode devolver um transaction request
/// PENDING esperando resposta de um challenge (SANDBOX_TAN) antes de
/// completar a transferência — esse fluxo de OTP ainda não está tratado
/// aqui (ver TransferUseCase).
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

struct TransactionRequestResponseDTO: Decodable {
    let id: String?
    let status: String?
}
