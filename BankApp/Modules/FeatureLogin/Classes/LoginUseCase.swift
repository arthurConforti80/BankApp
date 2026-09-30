//
//  LoginUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation
import Core

/// Orchestrates authentication by calling the shared API client.
/// Knows nothing about SwiftUI, knows nothing about the ViewModel, it only
/// knows how to authenticate.
public final class LoginUseCase: LoginUseCaseProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func execute(username: String, password: String) async throws {
        try await apiClient.directLogin(username: username, password: password)
    }
}
