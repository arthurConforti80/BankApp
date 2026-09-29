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

/// Autoriza uma empresa (counterparty já cadastrado) a debitar
/// automaticamente da conta. Ver comentário em CreateDirectDebitRequestDTO.
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

    public func createDirectDebit(
        for account: Account,
        counterpartyId: String,
        startDate: Date,
        endDate: Date?
    ) async throws {
        let body = CreateDirectDebitRequestDTO(
            counterparty_id: counterpartyId,
            date_signed: dateFormatter.string(from: Date()),
            date_starts: dateFormatter.string(from: startDate),
            date_expires: endDate.map { dateFormatter.string(from: $0) }
        )
        let _: DirectDebitResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/direct-debit",
            body: body
        )
    }
}
