//
//  HomeViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation
import Combine
import Core
import FeatureAccounts
import FeatureCards

/// Fica no target do app, não em nenhum feature module — ela precisa
/// conhecer tanto FeatureAccounts quanto FeatureCards pra combinar as duas
/// listas numa única tela, e só o target de composição pode fazer isso sem
/// violar a fronteira de módulo entre features.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var cards: [CreditCard] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let accountsUseCase: AccountsUseCaseProtocol
    private let cardsUseCase: CardsUseCaseProtocol

    init(accountsUseCase: AccountsUseCaseProtocol, cardsUseCase: CardsUseCaseProtocol) {
        self.accountsUseCase = accountsUseCase
        self.cardsUseCase = cardsUseCase
    }

    func load() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                async let accountsResult = accountsUseCase.fetchAccounts()
                async let cardsResult = cardsUseCase.fetchCards()
                let (fetchedAccounts, fetchedCards) = try await (accountsResult, cardsResult)
                accounts = fetchedAccounts
                cards = fetchedCards
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Não foi possível carregar contas e cartões."
            }
        }
    }
}
