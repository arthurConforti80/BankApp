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

    /// Chamado quando o login é bem-sucedido. Quem decide o que fazer com
    /// isso (navegar pra tela de contas) é o Coordinator, não a ViewModel —
    /// ela só avisa que terminou.
    public var onLoginSucceeded: (() -> Void)?

    private let loginUseCase: LoginUseCaseProtocol

    public init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    public func login() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha usuário e senha."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await loginUseCase.execute(username: username, password: password)
                isLoading = false
                onLoginSucceeded?()
            } catch {
                isLoading = false
                errorMessage = "Não foi possível autenticar. Verifique as credenciais."
            }
        }
    }
}
