//
//  CounterpartyUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Core

public protocol CounterpartyUseCaseProtocol {
    /// Returns the created `counterparty_id`, to be reused in the
    /// recurring payment and direct debit forms (there's still no
    /// beneficiary listing screen).
    @discardableResult
    func createCounterparty(
        for account: Account,
        name: String,
        nickname: String?,
        iban: String,
        bankName: String?
    ) async throws -> String
}

/// Registers a beneficiary (counterparty) by IBAN for an account. See the
/// comment on CreateCounterpartyRequestDTO about the schema not yet
/// confirmed against the real sandbox.
public final class CounterpartyUseCase: CounterpartyUseCaseProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    @discardableResult
    public func createCounterparty(
        for account: Account,
        name: String,
        nickname: String?,
        iban: String,
        bankName: String?
    ) async throws -> String {
        let body = CreateCounterpartyRequestDTO(
            name: name,
            description: nickname,
            currency: account.currency ?? "EUR",
            other_account_routing_scheme: "IBAN",
            other_account_routing_address: iban,
            other_account_secondary_routing_scheme: "",
            other_account_secondary_routing_address: "",
            other_bank_routing_scheme: "BIC",
            other_bank_routing_address: bankName ?? "",
            other_branch_routing_scheme: "",
            other_branch_routing_address: "",
            is_beneficiary: true,
            bespoke: []
        )
        let response: CounterpartyResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/counterparties",
            body: body
        )
        guard let counterpartyId = response.counterparty_id else {
            throw CounterpartyUseCaseError.missingCounterpartyId
        }
        return counterpartyId
    }
}

public enum CounterpartyUseCaseError: Error {
    case missingCounterpartyId
}
