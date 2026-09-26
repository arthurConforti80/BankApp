//
//  LoginCoordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import UIKit
import SwiftUI
import Core

/// Orquestra a tela de login e avisa quem o chamou quando o fluxo termina.
/// Deliberadamente não sabe nada sobre autenticação em si — isso é 100%
/// responsabilidade do LoginUseCase, chamado pela ViewModel.
public final class LoginCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let onFinished: (String) -> Void

    public init(navigationController: UINavigationController, onFinished: @escaping (String) -> Void) {
        self.navigationController = navigationController
        self.onFinished = onFinished
    }

    @MainActor public func start() {
        let viewModel = LoginViewModel(loginUseCase: LoginUseCase())
        viewModel.onLoginSucceeded = { [weak self] username in
            self?.onFinished(username)
        }

        let loginView = LoginView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: loginView)
        navigationController.setViewControllers([hostingController], animated: false)
    }
}
