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
    func fetchRecentTransactions(for account: Account, limit: Int) async throws -> [Transaction]
}

/// Fetches the accounts via Core.OBPAPIClient and maps the API DTO to the
/// domain Entity. The DTO never leaves this file, the ViewModel only ever
/// sees `Account`.
///
/// The statement (fetchRecentTransactions) delegates to Core.TransactionsService,
/// shared with FeatureCards. See the comment in TransactionsService.swift
/// for why that logic lives in Core and not here.
public final class AccountsUseCase: AccountsUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let transactionsService: TransactionsServiceProtocol

    public init(apiClient: OBPAPIClient = .shared, transactionsService: TransactionsServiceProtocol = TransactionsService()) {
        self.apiClient = apiClient
        self.transactionsService = transactionsService
    }

    public func fetchAccounts() async throws -> [Account] {
        let response: AccountsResponseDTO = try await apiClient.get(path: "/my/accounts")
        return response.accounts.map { dto in
            Account(
                id: dto.id,
                bankId: dto.bankId,
                label: dto.label ?? "Unnamed account",
                accountType: dto.accountType,
                iban: dto.accountRoutings.first(where: { $0.scheme == "IBAN" })?.address
            )
        }
    }

    public func fetchRecentTransactions(for account: Account, limit: Int) async throws -> [Transaction] {
        try await transactionsService.fetchRecentTransactions(bankId: account.bankId, accountId: account.id, limit: limit)
    }
}
