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
import FeatureProducts
import FeatureFX
import FeatureTransfer

final class HomeCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let username: String

    init(navigationController: UINavigationController, username: String) {
        self.navigationController = navigationController
        self.username = username
    }

    @MainActor func start() {
        let viewModel = HomeViewModel(
            username: username,
            accountsUseCase: AccountsUseCase(),
            cardsUseCase: CardsUseCase(),
            productsUseCase: ProductsUseCase(),
            fxUseCase: FxUseCase()
        )
        let homeView = HomeView(
            viewModel: viewModel,
            onSelectAccount: { [weak self] account in self?.showAccountDetail(account) },
            onSelectCard: { [weak self] card in self?.showCardDetail(card) },
            onSelectPayments: { [weak self, weak viewModel] in
                guard let account = viewModel?.accounts.first else { return }
                self?.showPaymentsHub(from: account)
            }
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

    // MARK: - Pagamentos

    @MainActor private func showPaymentsHub(from account: Account) {
        let view = TransferHubView(
            onNewTransfer: { [weak self] in self?.showTransfer(from: account) },
            onNewCounterparty: { [weak self] in self?.showCounterpartyForm(from: account) },
            onStandingOrder: { [weak self] in self?.showStandingOrderForm(from: account) },
            onDirectDebit: { [weak self] in self?.showDirectDebitForm(from: account) },
            onBack: { [weak self] in self?.navigationController.popViewController(animated: true) }
        )
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }

    @MainActor private func showTransfer(from account: Account) {
        let viewModel = TransferViewModel(fromAccount: account, transferUseCase: TransferUseCase())
        let view = TransferView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }

    @MainActor private func showCounterpartyForm(from account: Account) {
        let viewModel = CounterpartyFormViewModel(account: account, useCase: CounterpartyUseCase())
        let view = CounterpartyFormView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }

    @MainActor private func showStandingOrderForm(from account: Account) {
        let viewModel = StandingOrderFormViewModel(account: account, useCase: StandingOrderUseCase())
        let view = StandingOrderFormView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }

    @MainActor private func showDirectDebitForm(from account: Account) {
        let viewModel = DirectDebitFormViewModel(account: account, useCase: DirectDebitUseCase())
        let view = DirectDebitFormView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }
}
