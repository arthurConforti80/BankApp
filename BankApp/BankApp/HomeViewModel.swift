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

    /// Usuário OBP autenticado (ex.: "Robert.Us.01"), só pra saudação e
    /// avatar da Home — a API não devolve nome de exibição.
    let username: String

    private let accountsUseCase: AccountsUseCaseProtocol
    private let cardsUseCase: CardsUseCaseProtocol

    init(username: String, accountsUseCase: AccountsUseCaseProtocol, cardsUseCase: CardsUseCaseProtocol) {
        self.username = username
        self.accountsUseCase = accountsUseCase
        self.cardsUseCase = cardsUseCase
    }

    /// Primeiro nome extraído do usuário (ex.: "Robert.Us.01" -> "Robert").
    var displayName: String {
        username.split(separator: ".").first.map(String.init) ?? username
    }

    /// Iniciais pro avatar: uma letra de cada um dos dois primeiros
    /// componentes alfabéticos do usuário (ex.: "Robert.Us.01" -> "RU").
    var initials: String {
        let letterComponents = username
            .split(separator: ".")
            .filter { $0.contains(where: { $0.isLetter }) }
        let letters = letterComponents.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
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
