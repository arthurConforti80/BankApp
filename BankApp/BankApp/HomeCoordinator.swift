//
//  HomeCoordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import UIKit
import SwiftUI
import Core
import FeatureAccounts
import FeatureCards

final class HomeCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let username: String

    init(navigationController: UINavigationController, username: String) {
        self.navigationController = navigationController
        self.username = username
    }

    @MainActor func start() {
        let viewModel = HomeViewModel(username: username, accountsUseCase: AccountsUseCase(), cardsUseCase: CardsUseCase())
        let homeView = HomeView(
            viewModel: viewModel,
            onSelectAccount: { [weak self] account in self?.showAccountDetail(account) },
            onSelectCard: { [weak self] card in self?.showCardDetail(card) }
        )
        let hostingController = UIHostingController(rootView: homeView)
        navigationController.pushViewController(hostingController, animated: true)
    }

    @MainActor private func showAccountDetail(_ account: Account) {
        let viewModel = AccountDetailViewModel(account: account, accountsUseCase: AccountsUseCase())
        let view = AccountDetailView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }

    @MainActor private func showCardDetail(_ card: CreditCard) {
        let viewModel = CardDetailViewModel(card: card, cardsUseCase: CardsUseCase())
        let view = CardDetailView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }
}
