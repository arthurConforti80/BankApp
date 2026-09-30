//
//  AppCoordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import UIKit
import Core
import FeatureLogin

/// Root coordinator. Decides which feature coordinator starts the app and
/// handles the transition between them. No authentication or data logic
/// lives here, just navigation orchestration between modules.
@MainActor
public final class AppCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private var childCoordinator: Coordinator?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        showLogin()
    }

    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController) { [weak self] username in
            self?.showHome(username: username)
        }
        childCoordinator = loginCoordinator
        loginCoordinator.start()
    }

    private func showHome(username: String) {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, username: username)
        childCoordinator = homeCoordinator
        homeCoordinator.start()
    }
}
