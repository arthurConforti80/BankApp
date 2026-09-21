//
//  AppCoordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import UIKit
import Core
import FeatureLogin

/// Coordinator raiz. Decide qual feature Coordinator inicia o app e faz a
/// transição entre eles — nenhuma lógica de autenticação ou de dado mora
/// aqui, só orquestração de navegação entre módulos.
public final class AppCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private var childCoordinator: Coordinator?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @MainActor public func start() {
        showLogin()
    }

    @MainActor private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController) { [weak self] in
            self?.showHome()
        }
        childCoordinator = loginCoordinator
        loginCoordinator.start()
    }

    @MainActor private func showHome() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        childCoordinator = homeCoordinator
        homeCoordinator.start()
    }
}
