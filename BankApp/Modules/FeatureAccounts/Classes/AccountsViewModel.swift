//
//  AccountsViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class AccountsViewModel: ObservableObject {
    @Published public var accounts: [Account] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    private let accountsUseCase: AccountsUseCaseProtocol

    public init(accountsUseCase: AccountsUseCaseProtocol) {
        self.accountsUseCase = accountsUseCase
    }

    public func loadAccounts() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                accounts = try await accountsUseCase.fetchAccounts()
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Não foi possível carregar as contas."
            }
        }
    }
}
