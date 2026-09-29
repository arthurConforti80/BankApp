//
//  CounterpartyUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Core

public protocol CounterpartyUseCaseProtocol {
    func createCounterparty(
        for account: Account,
        name: String,
        nickname: String?,
        iban: String,
        bankName: String?
    ) async throws
}

/// Registra um beneficiário (counterparty) por IBAN pra uma conta. Ver
/// comentário em CreateCounterpartyRequestDTO sobre o schema ainda não
/// confirmado contra a sandbox real.
public final class CounterpartyUseCase: CounterpartyUseCaseProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func createCounterparty(
        for account: Account,
        name: String,
        nickname: String?,
        iban: String,
        bankName: String?
    ) async throws {
        let body = CreateCounterpartyRequestDTO(
            name: name,
            description: nickname,
            other_account_routing_scheme: "IBAN",
            other_account_routing_address: iban,
            other_bank_routing_scheme: "BIC",
            other_bank_routing_address: bankName ?? "",
            is_beneficiary: true
        )
        let _: CounterpartyResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/counterparties",
            body: body
        )
    }
}
