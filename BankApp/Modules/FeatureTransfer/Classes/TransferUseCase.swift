//
//  TransferUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation
import Core

/// Resultado de uma tentativa de transferência: ou completa direto, ou a
/// sandbox pede confirmação extra (SANDBOX_TAN) antes de liberar o valor —
/// o mesmo padrão de um MFA real, disparado pela própria API conforme um
/// limite configurado no lado do banco, não pelo app.
public enum TransferOutcome {
    case completed
    case challengeRequired(transactionRequestId: String, challengeId: String)
}

public protocol TransferUseCaseProtocol {
    func transfer(
        from account: Account,
        destinationIBAN: String,
        amount: Decimal,
        currency: String,
        description: String
    ) async throws -> TransferOutcome

    func answerChallenge(
        from account: Account,
        transactionRequestId: String,
        challengeId: String,
        code: String
    ) async throws
}

/// Cria um transaction request do tipo SEPA na conta de origem. Se a
/// sandbox devolver status "INITIATED" com um challenge, a UI precisa
/// responder esse desafio (ver answerChallenge) antes da transferência ser
/// efetivada — esse fluxo completo ainda NÃO foi validado ponta a ponta
/// contra a sandbox real (ver comentário em TransactionRequestDTO sobre o
/// schema do challenge).
public final class TransferUseCase: TransferUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let requestType = "SEPA"

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func transfer(
        from account: Account,
        destinationIBAN: String,
        amount: Decimal,
        currency: String,
        description: String
    ) async throws -> TransferOutcome {
        let body = TransactionRequestDTO(
            to: TransactionRequestDTO.Counterparty(iban: destinationIBAN),
            value: TransactionRequestDTO.Value(currency: currency, amount: Self.formattedAmount(amount)),
            description: description
        )

        let response: TransactionRequestResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/transaction-request-types/\(requestType)/transaction-requests",
            body: body
        )

        if response.status == "INITIATED",
           let requestId = response.id,
           let challengeId = response.challenge?.id {
            return .challengeRequired(transactionRequestId: requestId, challengeId: challengeId)
        }
        return .completed
    }

    public func answerChallenge(
        from account: Account,
        transactionRequestId: String,
        challengeId: String,
        code: String
    ) async throws {
        let body = ChallengeAnswerDTO(id: challengeId, answer: code)
        let _: TransactionRequestResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/transaction-request-types/\(requestType)/transaction-requests/\(transactionRequestId)/challenge",
            body: body
        )
    }

    private static func formattedAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
    }
}
