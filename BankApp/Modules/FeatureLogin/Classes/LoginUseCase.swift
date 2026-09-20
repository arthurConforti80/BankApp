//
//  LoginUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation
import Core

/// Orquestra a autenticação chamando o client de API compartilhado.
/// Não conhece SwiftUI, não conhece a ViewModel — só sabe autenticar.
public final class LoginUseCase: LoginUseCaseProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func execute(username: String, password: String) async throws {
        try await apiClient.directLogin(username: username, password: password)
    }
}
