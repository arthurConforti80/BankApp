//
//  AccountsCoordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import UIKit
import SwiftUI
import Core

public final class AccountsCoordinator: Coordinator {
    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @MainActor public func start() {
        let viewModel = AccountsViewModel(accountsUseCase: AccountsUseCase())
        let accountsView = AccountsListView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: accountsView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}
