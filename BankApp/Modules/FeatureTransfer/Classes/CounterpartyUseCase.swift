//
//  CounterpartyUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Core

public protocol CounterpartyUseCaseProtocol {
    /// Retorna o `counterparty_id` criado, pra ser reaproveitado nos
    /// formulários de pagamento recorrente e débito automático (ainda
    /// sem uma tela de listagem de beneficiários).
    @discardableResult
    func createCounterparty(
        for account: Account,
        name: String,
        nickname: String?,
        iban: String,
        bankName: String?
    ) async throws -> String
}

/// Registra um beneficiário (counterparty) por IBAN pra uma conta. Ver
/// comentário em CreateCounterpartyRequestDTO sobre o schema ainda não
/// confirmado contra a sandbox real.
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
