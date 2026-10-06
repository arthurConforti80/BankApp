//
//  DirectDebitUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Core

public protocol DirectDebitUseCaseProtocol {
    func createDirectDebit(
        for account: Account,
        counterpartyId: String,
        startDate: Date,
        endDate: Date?
    ) async throws
}

/// Authorizes a company (an already registered counterparty) to
/// automatically debit the account. See the comment on CreateDirectDebitRequestDTO.
public final class DirectDebitUseCase: DirectDebitUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    private static let farFutureExpiry = "2099-12-31T00:00:00Z"

    public func createDirectDebit(
        for account: Account,
        counterpartyId: String,
        startDate: Date,
        endDate: Date?
    ) async throws {
        let userId = try await apiClient.currentUserId()
        let customerId = try await apiClient.currentCustomerId(bankId: account.bankId)

        let body = CreateDirectDebitRequestDTO(
            customer_id: customerId,
            user_id: userId,
            counterparty_id: counterpartyId,
            date_signed: dateFormatter.string(from: Date()),
            date_starts: dateFormatter.string(from: startDate),
            date_expires: endDate.map { dateFormatter.string(from: $0) } ?? Self.farFutureExpiry
        )
        let _: DirectDebitResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/direct-debit",
            body: body
        )
    }
}
