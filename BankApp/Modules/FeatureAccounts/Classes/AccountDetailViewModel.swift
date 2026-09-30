//
//  AccountDetailViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class AccountDetailViewModel: ObservableObject {
    @Published public var transactions: [Transaction] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    public let account: Account
    private let accountsUseCase: AccountsUseCaseProtocol

    public init(account: Account, accountsUseCase: AccountsUseCaseProtocol) {
        self.account = account
        self.accountsUseCase = accountsUseCase
    }

    public func loadTransactions() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                transactions = try await accountsUseCase.fetchRecentTransactions(for: account, limit: 5)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Couldn't load the statement."
            }
        }
    }
}
