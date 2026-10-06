//
//  LoginCoordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import UIKit
import SwiftUI
import Core

/// Orchestrates the login screen and notifies its caller when the flow
/// finishes. Deliberately knows nothing about authentication itself, that
/// is 100% LoginUseCase's responsibility, called by the ViewModel.
@MainActor
public final class LoginCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let onFinished: (String) -> Void

    public init(navigationController: UINavigationController, onFinished: @escaping (String) -> Void) {
        self.navigationController = navigationController
        self.onFinished = onFinished
    }

    public func start() {
        let viewModel = LoginViewModel(loginUseCase: LoginUseCase())
        viewModel.onLoginSucceeded = { [weak self] username in
            self?.onFinished(username)
        }

        let loginView = LoginView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: loginView)
        navigationController.setViewControllers([hostingController], animated: false)
    }
}
