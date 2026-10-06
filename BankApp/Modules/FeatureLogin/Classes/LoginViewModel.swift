//
//  LoginViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation
import Combine

@MainActor
public final class LoginViewModel: ObservableObject {
    @Published public var username: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    /// Called when login succeeds. Deciding what to do with that (navigate
    /// to the accounts screen) is the Coordinator's job, not the ViewModel's;
    /// it just announces that it finished.
    public var onLoginSucceeded: ((String) -> Void)?

    private let loginUseCase: LoginUseCaseProtocol

    public init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    public func login() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your username and password."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await loginUseCase.execute(username: username, password: password)
                isLoading = false
                onLoginSucceeded?(username)
            } catch {
                isLoading = false
                errorMessage = "Couldn't sign in. Check your credentials."
            }
        }
    }
}
