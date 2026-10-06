//
//  TransferUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation
import Core

/// Result of a transfer attempt: it either completes directly, or the
/// sandbox asks for extra confirmation (SANDBOX_TAN) before releasing the
/// amount, the same pattern as real MFA, triggered by the API itself based
/// on a limit configured on the bank's side, not by the app.
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

/// Creates a SEPA-type transaction request on the source account. If the
/// sandbox returns an "INITIATED" status with a challenge, the UI needs to
/// answer that challenge (see answerChallenge) before the transfer is
/// finalized. This full flow has NOT yet been validated end to end against
/// the real sandbox (see the comment on TransactionRequestDTO about the
/// challenge schema).
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
