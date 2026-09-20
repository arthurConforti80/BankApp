//
//  AccountsUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation
import Core

public protocol AccountsUseCaseProtocol {
    func fetchAccounts() async throws -> [Account]
}

/// Busca as contas via Core.OBPAPIClient e mapeia o DTO da API para a
/// Entity de domínio. O DTO nunca sai daqui — a ViewModel só vê `Account`.
public final class AccountsUseCase: AccountsUseCaseProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func fetchAccounts() async throws -> [Account] {
        let response: AccountsResponseDTO = try await apiClient.get(path: "/my/accounts")
        return response.accounts.map { dto in
            Account(
                id: dto.id,
                bankId: dto.bankId,
                label: dto.label,
                balance: Decimal(string: dto.balance.amount) ?? 0,
                currency: dto.balance.currency
            )
        }
    }
}
